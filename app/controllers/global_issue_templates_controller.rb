class GlobalIssueTemplatesController < ApplicationController
  unloadable
  include RedmineIssueTemplates::TemplateOrdering

  include IssueTemplatesHelper
  helper :issues
  include IssuesHelper
  menu_item :issues

  before_filter :require_admin, :find_user
  before_filter :find_object, :only => [ :show, :edit, :update, :destroy ]

  #
  # Action for global template : Admin right is required.
  #
  def index
    @trackers = Tracker.all
    @template_map = Hash::new
    @trackers.each do |tracker|
      templates = GlobalIssueTemplate.where('tracker_id = ?',
                                      tracker.id).order('position')
      if templates.any?
        @template_map[Tracker.find(tracker.id)] = templates
      end
    end
    render :layout => !request.xhr?
  end

  def new
    @trackers = Tracker.all
    @projects = Project.all
    @global_issue_template = GlobalIssueTemplate.new(:author => @user,
                                        :tracker => @tracker)
  end

  def create
    new
    @global_issue_template.safe_attributes = params[:global_issue_template]
    if @global_issue_template.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to global_issue_template_path(@global_issue_template)
    else
      render 'new'
    end
  end

  def show
    @projects = Project.all
  end

  def edit
    @projects = Project.all
  end

  def update
    @projects = Project.all
    @global_issue_template.safe_attributes = params[:global_issue_template]
    if @global_issue_template.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to global_issue_template_path(@global_issue_template)
    else
      respond_to do |format|
        format.html { render :action => 'show' }
      end
    end
  end

  def destroy
    if @global_issue_template.destroy
      flash[:notice] = l(:notice_successful_delete)
      redirect_to global_issue_templates_path
    end
  end

  # preview
  def preview
    @text = (params[:global_issue_template] ? params[:global_issue_template][:description] : nil)
    @global_issue_template = GlobalIssueTemplate.find(params[:id]) if params[:id]
    render :partial => 'common/preview'
  end

  private

  # Reorder templates
  def find_user
    @user = User.current
  end

  def find_object
    @trackers = Tracker.all
    @global_issue_template = GlobalIssueTemplate.find(params[:id])
  end

end
