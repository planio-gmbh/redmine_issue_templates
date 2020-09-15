class GlobalIssueTemplatesController < ApplicationController
  include Concerns::IssueTemplatesCommon

  helper IssueTemplatesHelper

  before_filter :require_admin
  before_filter :find_template, only: [:show, :edit, :update, :destroy]

  def index
    @trackers = Tracker.sorted
    @template_map = Hash[
      @trackers.map do |t|
        templates = GlobalIssueTemplate.search_by_tracker(t.id).sorted
        [t.id, templates] if templates.any?
      end.compact
    ]
    @orphaned = GlobalIssueTemplate.orphaned
  end

  def new
    find_projects_and_trackers
    @template = GlobalIssueTemplate.new
  end

  def create
    @template = GlobalIssueTemplate.new
    @template.safe_attributes = template_params
    @template.checklist_json = checklists.to_json if checklists
    @template.author = User.current

    if @template.save
      redirect_to global_issue_templates_path, notice: l(:notice_successful_create)
    else
      find_projects_and_trackers
      render 'new'
    end
  end

  def show
  end

  def edit
    find_projects_and_trackers
  end

  def update
    @template.safe_attributes = template_params
    @template.checklist_json = checklists.to_json
    if @template.save
      respond_to do |format|
        format.html{
          redirect_to global_issue_templates_path, notice: l(:notice_successful_update)
        }
        format.js { head 200 }
      end
    else
      respond_to do |format|
        format.html{
          find_projects_and_trackers
          render 'edit'
        }
        format.js{ head 422 }
      end
    end
  end

  def destroy
    unless @template.destroy
      flash[:error] = l(:enabled_template_cannot_destroy)
      redirect_to global_issue_template_path(@template)
    else
      flash[:notice] = l(:notice_successful_delete)
      redirect_to global_issue_templates_path
    end
  end

  private

  def find_projects_and_trackers
    @projects = Project.all
    @trackers = Tracker.sorted
  end

  def find_template
    @template = GlobalIssueTemplate.find params[:id]
  end

  def template_params
    params.require(:template)
          .permit(:title, :tracker_id, :issue_title, :description, :note, :is_default, :enabled,
                  :author_id, :position, project_ids: [], checklists: [])
  end

end
