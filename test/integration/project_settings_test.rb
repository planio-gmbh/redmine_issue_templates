require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ProjectSettingsTest < Redmine::IntegrationTest
  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :enabled_modules,
           :workflows

  setup do
    @user = User.find_by_login 'admin'
    @project = Project.find 1
  end

  def test_should_show_project_settings_if_enabled
    log_user('admin', 'admin')

    get '/projects/ecookbook/settings/issue_templates'
    assert_response :success
    assert_select '#content ul li a.selected', text: 'Issue templates', count: 0

    @project.enabled_modules.create! name: 'issue_templates'
    get '/projects/ecookbook/settings/issue_templates'
    assert_response :success
    assert_select '#content ul li a.selected', text: 'Issue templates'

    assert_select 'a', text: 'Template list', href: '/projects/ecookbook/issue_templates'
    assert_select 'a', text: 'Add template', href: '/projects/ecookbook/issue_templates/new'
  end

  def test_should_save_project_settings
    @project.enabled_modules.create! name: 'issue_templates'
    log_user('admin', 'admin')

    setting = IssueTemplateSetting.find_or_create @project.id

    patch '/projects/ecookbook/issue_templates_settings', params: {
      settings: {
        inherit_templates: '1',
        help_message: 'help message here'
      }
    }

    assert_redirected_to '/projects/ecookbook/settings/issue_templates'
    follow_redirect!
    assert_response :success
    assert_select 'textarea', text: 'help message here'

    setting.reload
    assert setting.inherit_templates?
    assert_equal 'help message here', setting.help_message
  end

  def test_should_require_permission
    @project.enabled_modules.create! name: 'issue_templates'
    r = Role.find 2
    user = User.find 3
    log_user('dlopper', 'foo')

    setting = IssueTemplateSetting.find_or_create @project.id

    get '/projects/ecookbook/settings'
    assert_response :success
    assert_select '#content ul li a.selected', text: 'Issue templates', count: 0

    patch '/projects/ecookbook/issue_templates_settings', params: {
      settings: {
        inherit_templates: '1',
        help_message: 'help message here'
      }
    }
    assert_response 403

    r.add_permission! :edit_issue_templates
    assert user.allowed_to? :edit_issue_templates, @project
    get '/projects/ecookbook/settings/issue_templates'
    assert_response :success
    assert_select '#content ul li a.selected', text: 'Issue templates'
    assert_select 'h3', text: 'Issue templates'
    assert_select 'h3', text: 'Settings', count: 0

    r.add_permission! :manage_issue_templates
    user = User.find 3
    assert user.allowed_to? :manage_issue_templates, @project
    get '/projects/ecookbook/settings/issue_templates'
    assert_response :success
    assert_select '#content ul li a.selected', text: 'Issue templates'
    assert_select 'h3', text: 'Issue templates'
    assert_select 'h3', text: 'Settings'


    patch '/projects/ecookbook/issue_templates_settings', params: {
      settings: {
        inherit_templates: '0',
        help_message: 'help'
      }
    }
    assert_redirected_to '/projects/ecookbook/settings/issue_templates'

    setting.reload
    refute setting.inherit_templates?
    assert_equal 'help', setting.help_message
  end

end

