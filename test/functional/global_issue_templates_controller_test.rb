require File.expand_path('../../test_helper', __FILE__)

class GlobalIssueTemplatesControllerTest < Redmine::ControllerTest
  fixtures :projects, :users, :trackers,
           :global_issue_templates,
           :global_issue_templates_projects

  include Redmine::I18n

  def setup
    @request.session[:user_id] = 1 # Admin
    @project = Project.find(1)
    @project.enabled_modules << EnabledModule.new(name: 'issue_templates')
    @project.save!
  end

  def test_get_index
    get :index
    assert_response :success
    assert_template 'index'
    assert map = assigns(:template_map)
    assert map.present?
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_edit
    get :edit, id: 2
    assert_response :success
    assert_equal 2, assigns(:template).id
  end

  def test_update
    put :update, id: 2,
        template: { description: 'Update Test Global template2' }
    assert_redirected_to global_issue_templates_path
    assert_equal 'Update Test Global template2', GlobalIssueTemplate.find(2).description
  end

  def test_destroy_template
    post :destroy, id: 2
    assert_redirected_to global_issue_templates_path
    assert_raise(ActiveRecord::RecordNotFound) { GlobalIssueTemplate.find(2) }
  end

  def test_new_template
    get :new
    assert_response :success

    template = assigns(:template)
    assert_not_nil template
    assert template.title.blank?
    assert template.description.blank?
    assert template.note.blank?
    assert template.tracker.blank?
  end

  def test_create_template
    assert_difference ->{ GlobalIssueTemplate.count} do
      post :create, template: {
        title: 'Global Template newtitle for creation test', note: 'Global note for creation test',
        description: 'Global Template description for creation test',
        tracker_id: 1, enabled: 1, author_id: 1
      }
    end

    assert_redirected_to global_issue_templates_path
    assert template = GlobalIssueTemplate.last
    assert_equal('Global Template newtitle for creation test', template.title)
    assert_equal('Global note for creation test', template.note)
    assert_equal('Global Template description for creation test', template.description)
    assert_equal(1, template.tracker.id)
    assert_equal(1, template.author.id)
  end

  def test_create_template_fail
    assert_no_difference ->{ GlobalIssueTemplate.count} do
      post :create, template: {
        title: '', note: 'note',
        description: 'description', tracker_id: 1, enabled: 1,
        author_id: 1 }
    end
    assert_response :success
    assert assigns(:template).errors[:title]
    assert_select 'div#errorExplanation ul li', text: 'Title cannot be blank'
  end

end
