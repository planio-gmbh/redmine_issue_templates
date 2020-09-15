require File.expand_path('../test_helper', __dir__)

class IssueTemplatesControllerTest < Redmine::ControllerTest
  fixtures :projects, :users, :roles, :trackers, :members, :member_roles, :enabled_modules,
           :issue_templates,
           :projects_trackers

  include Redmine::I18n

  def setup
    @request.session[:user_id] = 2
    # Enabled Template module
    @project = Project.find(1)
    @project.enabled_modules << EnabledModule.new(name: 'issue_templates')
    @project.save!

    Role.find(1).add_permission! :show_issue_templates
    Role.find(1).add_permission! :edit_issue_templates
  end

  def test_get_index_with_non_existing_project
    # set non existing project
    get :index, project_id: 100
    assert_response 404
  end

  def test_get_index_without_show_permission
    Role.find(1).remove_permission! :show_issue_templates
    Role.find(1).remove_permission! :edit_issue_templates
    get :index, project_id: 1
    assert_response 403
  end

  def test_get_index
    get :index, project_id: 1
    assert_response :success
    assert_template 'index'
    assert assigns(:global_templates_map)
    assert assigns(:template_map)
    assert assigns(:inherited_map)
  end

  def test_show_with_non_existing_template
    assert_raise ActiveRecord::RecordNotFound do
      get :show, id: 100, project_id: 1
    end
  end

  test 'load should load project template' do
    xhr :get, :load, project_id: @project, id: 'project-1'
    assert_response :success
    assert_match /description1/, response.body
  end

  test 'load should load global template' do
    xhr :get, :load, project_id: 1, id: 'global-1'
    assert_response :success
    assert_match /global description1/, response.body
  end

  test "load should only return project templates" do
    EnabledModule.create!(project_id: 2, name: 'issue_templates')
    Role.find(2).add_permission! :show_issue_templates
    assert_raise ActiveRecord::RecordNotFound do
      xhr :get, :load, project_id: 2, id: 'project-1'
    end
    assert_raise ActiveRecord::RecordNotFound do
      xhr :get, :load, project_id: 2, id: 'global-1'
    end
  end

  def test_new_template
    get :new, project_id: 1
    assert_response :success

    assert template = assigns(:template)
    assert template.title.blank?
    assert template.description.blank?
    assert template.note.blank?
    assert template.tracker.blank?
  end

  def test_create_template
    assert_difference ->{IssueTemplate.count} do
      post :create, project_id: 1, template: {
        title: 'newtitle', note: 'note',
        description: 'description', tracker_id: 1, enabled: 1, author_id: 3
      }
    end

    assert_redirected_to project_issue_templates_path(project_id: 1)

    assert template = IssueTemplate.last
    assert_equal('newtitle', template.title)
    assert_equal('note', template.note)
    assert_equal('description', template.description)
    assert_equal(1, template.project.id)
    assert_equal(1, template.tracker.id)
    assert_equal(2, template.author.id)
  end

  def test_create_template_with_empty_title
    assert_no_difference ->{IssueTemplate.count} do
      post :create, template: { title: '', note: 'note',
                                 description: 'description', tracker_id: 1, enabled: 1,
                              }, project_id: 1

      assert_response :success
      assert t = assigns(:template)
      assert_equal 'note', t.note
      assert t.errors[:title]
    end
  end

  def test_update_template
    put :update, id: 2, project_id: @project,
        template: { description: 'Update Test template2' }
    assert_redirected_to project_issue_templates_path(@project)
    issue_template = IssueTemplate.find(2)
    assert_equal 'Update Test template2', issue_template.description
  end

  def test_delete_template_fail_if_enabled
    post :destroy, id: 1, project_id: @project.id
    assert_redirected_to project_issue_template_path(@project, 1)
    assert_match(/Only disabled template can be destroyed/, flash[:error])
  end

  def test_delete_template_success_if_disabled
    template = IssueTemplate.find(1)
    template.update_attribute :enabled, false
    delete :destroy, id: 1, project_id: @project.id
    assert_redirected_to project_issue_templates_path(@project)
    assert_raise(ActiveRecord::RecordNotFound) { IssueTemplate.find(1) }
  end

  def test_update_template_does_only_change_safe_attributes
    put :update, id: 2, project_id: @project.id,
         template: { description: 'Update Test template2',
                     project_id: 2, author_id: 2 }
    assert_redirected_to project_issue_templates_path(@project)
    issue_template = IssueTemplate.find(2)
    assert_equal 'Update Test template2', issue_template.description
    assert_equal(1, issue_template.project.id)
    assert_equal(1, issue_template.author.id)
  end

  def test_child_project_index
    child_project_setup

    get :index, project_id: 1
    assert_response :success
    assert_template 'index'
    assert_select 'h2', text: l(:issue_templates)
    assert_select 'h2', text: l(:label_inherited_templates), count: 0

    get :index, project_id: 3
    assert_response :success
    assert_template 'index'
    assert_select 'h2', text: l(:issue_templates)
    assert_select 'h2', text: l(:label_inherited_templates), count: 0
  end

  def test_child_project_index_with_inherit_templates
    child_project_setup
    IssueTemplateSetting.find(3).update_column :inherit_templates, true
    Project.find(3).update_attribute :tracker_ids, [1,2,3]

    get :index, project_id: 3
    assert_response :success
    assert_template 'index'
    assert_select 'h2', text: l(:issue_templates)
    assert_select 'h2', text: l(:label_inherited_templates)
  end

  def child_project_setup
    @project = Project.find(3)
    @project.enabled_modules << EnabledModule.new(name: 'issue_templates')
    @project.save!

    # do as Admin
    @request.session[:user_id] = 1
  end

end
