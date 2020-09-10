require File.expand_path('../test_helper', __dir__)

class IssueTemplatesControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :trackers, :members, :member_roles, :enabled_modules,
           :issue_templates,
           :projects_trackers

  include Redmine::I18n

  def setup
    @controller = IssueTemplatesController.new
    @request = ActionController::TestRequest.new
    @request.session[:user_id] = 2
    @response = ActionController::TestResponse.new
    @request.env['HTTP_REFERER'] = '/'
    # Enabled Template module
    @project = Project.find(1)
    @project.enabled_modules << EnabledModule.new(name: 'issue_templates')
    @project.save!

    # Set default permission: show template
    Role.find(1).add_permission! :show_issue_templates
  end

  def test_get_index_with_non_existing_project
    # set non existing project
    get :index, project_id: 100
    assert_response 404
  end

  def test_get_index_without_show_permission
    Role.find(1).remove_permission! :show_issue_templates
    get :index, project_id: 1
    assert_response 403
  end

  def test_get_index_with_normal
    get :index, project_id: 1
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:global_issue_templates)
  end

  def test_show_with_non_existing_template
    get :show, id: 100, project_id: 1
    assert_response 404
  end

  def test_show_return_json_hash
    get :load, project_id: 1, issue_template: 1
    assert_response :success
    assert_equal 'description1', json_response['issue_template']['description']
  end

  def test_show_return_json_hash_of_global
    get :load, project_id: 1, issue_template: 1, template_type: 'global'
    assert_response :success
    assert_equal 'global description1', json_response['global_issue_template']['description']
  end

  def test_show_render_pulldown
    get :set_pulldown, project_id: 1, issue_tracker_id: 1
    tracker = Tracker.find(1)
    assert_response :success
    assert_template 'issue_templates/_template_pulldown'
    assert_select "optgroup[label=#{tracker.name}]"
  end

  def test_new_template
    edit_permission

    get :new, project_id: 1, author_id: 2
    assert_response :success

    template = assigns(:issue_template)
    assert_not_nil template
    assert template.title.blank?
    assert template.description.blank?
    assert template.note.blank?
    assert template.tracker.blank?
    assert_equal(2, template.author.id)
    assert_equal(1, template.project.id)
  end

  def test_create_template
    edit_permission

    num = IssueTemplate.count
    post :new, issue_template: { title: 'newtitle', note: 'note',
                                 description: 'description', tracker_id: 1, enabled: 1, author_id: 3 }, project_id: 1

    template = assigns(:issue_template)
    assert_response :redirect # show

    assert_equal(num + 1, IssueTemplate.count)

    assert_not_nil template
    assert_equal('newtitle', template.title)
    assert_equal('note', template.note)
    assert_equal('description', template.description)
    assert_equal(1, template.project.id)
    assert_equal(1, template.tracker.id)
    assert_equal(2, template.author.id)
  end

  def test_create_template_with_empty_title
    edit_permission

    num = IssueTemplate.count

    # when title blank, validation bloks to save.
    post :new, issue_template: { title: '', note: 'note',
                                 description: 'description', tracker_id: 1, enabled: 1,
                                 author_id: 1 }, project_id: 1

    assert_response :success
    assert_equal(num, IssueTemplate.count)
  end

  def test_preview_template
    edit_permission

    get :preview, issue_template: { description: 'h1. Test data.' }
    assert_template 'common/_preview'
    assert_select 'h1', /Test data\./, @response.body.to_s
  end

  def test_edit_template
    edit_permission

    put :edit, id: 2,
               issue_template: { description: 'Update Test template2' },
               project_id: 1
    project = Project.find 1
    assert_response :redirect # show
    issue_template = IssueTemplate.find(2)
    assert_redirected_to controller: 'issue_templates',
                         action: 'show', id: issue_template.id, project_id: project
    assert_equal 'Update Test template2', issue_template.description
  end

  def test_delete_template_fail_if_enabled
    edit_permission

    post :destroy, id: 1, project_id: 1
    project = Project.find 1
    assert_redirected_to controller: 'issue_templates',
                         action: 'show', project_id: project, id: 1
    assert_match(/Only disabled template can be destroyed/, flash[:error])
  end

  def test_delete_template_success_if_disabled
    edit_permission

    template = IssueTemplate.find(1)
    template.enabled = false
    template.save
    post :destroy, id: 1, project_id: 1
    project = Project.find 1
    assert_redirected_to controller: 'issue_templates',
                         action: 'index', project_id: project
    assert_raise(ActiveRecord::RecordNotFound) { IssueTemplate.find(1) }
  end

  def test_edit_template_failed_with_project_id_and_safe_attributes
    edit_permission

    put :edit, id: 2,
               issue_template: { description: 'Update Test template2',
                                 project_id: 2, author_id: 2 },
               project_id: 1
    project = Project.find 1
    assert_response :redirect # show
    issue_template = IssueTemplate.find(2)
    assert_redirected_to controller: 'issue_templates',
                         action: 'show', id: issue_template.id, project_id: project
    assert_equal 'Update Test template2', issue_template.description
    assert_equal(1, issue_template.project.id)
    assert_equal(1, issue_template.author.id)
  end

  def test_child_project_index
    child_project_setup

    get :index, project_id: 1
    assert_response :success
    assert_template 'index'
    assert_select 'h2', text: l(:issue_templates).to_s, count: 1
    assert !@response.body.match(%r{<h3>#{l(:label_inherited_templates)}</h3>})

    get :index, project_id: 3
    assert_response :success
    assert_template 'index'
    assert_select 'h2', text: l(:issue_templates).to_s, count: 1
    assert !@response.body.match(%r{<h3>#{l(:label_inherited_templates)}</h3>})
  end

  def test_child_project_index_with_inherit_templates
    child_project_setup

    setting = IssueTemplateSetting.find(3)
    setting.inherit_templates = true
    setting.save!

    get :index, project_id: 3
    assert_response :success
    assert_template 'index'
    assert_select 'h2', text: l(:issue_templates).to_s, count: 1
  end

  def test_child_project_render_pulldown_with_parent_template
    child_project_setup

    setting = IssueTemplateSetting.find(3)
    setting.inherit_templates = true
    setting.save!
    tracker = Tracker.find(1)
    get :set_pulldown, project_id: 3, issue_tracker_id: 1
    assert_template 'issue_templates/_template_pulldown'
    assert_select "optgroup[label='#{tracker.name}']"
    assert_select 'option[value="1"]'
    assert_select 'option[class="global"]'
  end

  def json_response
    ActiveSupport::JSON.decode @response.body
  end

  def child_project_setup
    @project = Project.find(3)
    @project.enabled_modules << EnabledModule.new(name: 'issue_templates')
    @project.save!

    # do as Admin
    @request.session[:user_id] = 1
  end

  def edit_permission
    Role.find(1).add_permission! :edit_issue_templates
  end
end
