require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class LayoutTest < Redmine::IntegrationTest
  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :enabled_modules,
           :workflows,
           :issue_templates

  setup do
    @project = Project.find 'ecookbook'
    EnabledModule.create name: 'issue_tracking', project: @project
  end

  def test_issue_template_not_visible_when_module_off

    # module -> disabled
    EnabledModule.where(name: 'issue_templates').delete_all

    log_user('admin', 'admin')
    get '/projects/ecookbook/issues'
    assert_response :success
    assert_select '#sidebar h3', count: 0, text: I18n.t('issue_templates')

    get '/projects/ecookbook/issues/new'
    assert_select 'div#template_area select#issue_template', 0
  end

  def test_issue_template_visible_when_module_on
    # module -> enabled
    EnabledModule.create! name: 'issue_templates', project: @project

    log_user('admin', 'admin')
    post '/projects/ecookbook/modules', params: {
      enabled_module_names: %w(issue_tracking issue_templates), commit: 'Save', id: 'ecookbook'
    }

    get '/projects/ecookbook/issues'
    assert_response :success
    assert_select '#sidebar h3', count: 1, text: I18n.t('issue_templates')
    assert_select 'a', text: 'Add template'
  end
end
