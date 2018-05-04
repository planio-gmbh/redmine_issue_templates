require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class IssueTemplatesSettingsControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :enabled_modules,
           :issue_templates

  setup do
    # Enabled Template module
    @project = Project.find 1
    @project.enabled_modules.create! name: 'issue_templates'
    @request.session[:user_id] = 2
  end

  test 'should 403 without permission' do
    patch :update, project_id: @project,
                settings: { enabled: '1', help_message: 'Hoo', inherit_templates: true },
                setting_id: 1, tab: 'issue_templates'
    assert_response 403
  end

  test 'non existing project should return 404' do
    # set non existing project
    patch :update,
      project_id: 'dummy',
      settings: { enabled: '1', help_message: 'Hoo', project_id: 2, inherit_templates: true }
    assert_response 404
  end

  test 'should save and redirect' do
    Role.find(1).add_permission! :manage_issue_templates
    patch :update,
      project_id: @project,
      settings: {
        enabled: '1', help_message: 'Hoo', project_id: 2, inherit_templates: true
      }
    assert_response :redirect
    assert_redirected_to controller: 'projects',
                         action: 'settings', id: @project, tab: 'issue_templates'
  end

  test 'should preview template setting' do
    post :preview, settings: { help_message: 'h1. Preview test.',
                               enabled: '1' },
                   project_id: @project
    assert_template 'common/_preview'
    assert_select 'h1', /Preview test\./, @response.body.to_s
  end
end
