class IssueTemplatesSettingsController < ApplicationController
  unloadable
  before_filter :find_project_by_project_id, :authorize, :find_user

  def update
    @issue_templates_setting = IssueTemplateSetting.find_or_create(@project.id)
    attribute = params[:settings]
    if @issue_templates_setting.update_attributes(:enabled => attribute[:enabled],
                                               :help_message => attribute[:help_message],
                                               :inherit_templates => attribute[:inherit_templates],
                                               :should_replaced => attribute[:should_replaced])

      flash[:notice] = l(:notice_successful_update)
    end
    redirect_to settings_project_path @project, :tab => 'issue_templates'
  end

  def preview
    @text = params[:settings][:help_message]
    render :partial => 'common/preview'
  end

  private
  def find_user
    @user = User.current
  end

end
