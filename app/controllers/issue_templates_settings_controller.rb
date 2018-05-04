class IssueTemplatesSettingsController < ApplicationController
  before_filter :find_project_by_project_id, except: :preview
  before_filter :authorize, except: :preview

  def update
    if params[:settings]
      issue_templates_setting = IssueTemplateSetting.find_or_create(@project.id)
      issue_templates_setting.safe_attributes = params[:settings]
      issue_templates_setting.save
      flash[:notice] = l(:notice_successful_update)
    end
    redirect_to controller: 'projects', action: 'settings', id: @project, tab: 'issue_templates'
  end

  def preview
    @text = params[:settings][:help_message]
    render partial: 'common/preview'
  end

end
