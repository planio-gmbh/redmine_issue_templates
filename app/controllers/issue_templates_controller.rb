class IssueTemplatesController < ApplicationController
  include Concerns::IssueTemplatesCommon

  before_action :find_project_by_project_id
  before_action :authorize

  before_action :find_template, only: [:show, :edit, :update, :destroy]

  accept_api_auth :index

  def index
    @trackers = @project.trackers.sorted
    templates = IssueTemplates::ProjectTemplates.new(project_id: @project.id,
                                                     tracker_id: @trackers.pluck(:id))
    @project_templates = templates.issue_templates(only_enabled: false)
    @orphaned = templates.orphaned

    @inherited_templates = templates.inherited_templates
    @global_issue_templates = templates.global_templates

    @template_map = templates_by_tracker @project_templates, @trackers
    @inherited_map = templates_by_tracker @inherited_templates, @trackers
    @global_templates_map = templates_by_tracker @global_issue_templates, @trackers

    respond_to do |format|
      format.html
      format.api
    end
  end

  def new
    find_trackers
    @template = if params[:copy_from].present?
      # in order to support cross-project copy, we should first implement
      # IssueTemplate.visible.
      IssueTemplate.where(project_id: @project.id).find(params[:copy_from]).copy
    else
      IssueTemplate.new
    end
  end

  def create
    @template = IssueTemplate.new
    @template.safe_attributes = template_params
    @template.checklist_json = checklists.to_json if checklists
    @template.author = User.current
    @template.project = @project

    if @template.save
      redirect_to project_issue_templates_path, notice: l(:notice_successful_create)
    else
      find_trackers
      render 'new'
    end
  end

  def show
  end

  def edit
    find_trackers
  end

  def update
    @template.safe_attributes = template_params
    @template.checklist_json = checklists.to_json
    if @template.save
      respond_to do |format|
        format.html{
          redirect_to project_issue_templates_path(@project), notice: l(:notice_successful_update)
        }
        format.js { head 200 }
      end
    else
      respond_to do |format|
        format.html{
          find_trackers
          render 'edit'
        }
        format.js{ head 422 }
      end
    end
  end


  def destroy
    if @template.destroy
      flash[:notice] = l(:notice_successful_delete)
      redirect_to project_issue_templates_path(@project)
    else
      flash[:error] = l(:enabled_template_cannot_destroy)
      redirect_to project_issue_template_path(@project, @template)
    end
  end

  # load template into issue form
  def load
    template_type, id = params[:id].to_s.split('-')
    if template_type.present? && id.present?
      templates = IssueTemplates::ProjectTemplates.new(project_id: @project.id)
      @setting = templates.setting
      @template = case template_type
        when 'global'
          templates.global_templates.find id
        when 'project'
          templates.issue_templates.find_by_id(id) ||
            templates.inherited_templates.find_by_id(id) ||
            raise(ActiveRecord::RecordNotFound)
      end
    end
    respond_to do |format|
      format.js {
        head 400 unless @template
      }
    end
  end


  private

  def find_template
    @template = IssueTemplate.where(project_id: @project.id).find params[:id]
  end

  def find_trackers
    @trackers = @project.trackers
  end

  def templates_by_tracker(templates, trackers)
    Hash[
      trackers.map do |t|
        tracker_templates = templates.search_by_tracker(t.id).sorted
        [t.id, tracker_templates] if tracker_templates.any?
      end.compact
    ]
  end

  def template_params
    params.require(:template).
      permit(:tracker_id, :title, :note, :issue_title, :description,
             :is_default, :enabled, :author_id, :position, :enabled_sharing,
             checklists: [])
  end
end
