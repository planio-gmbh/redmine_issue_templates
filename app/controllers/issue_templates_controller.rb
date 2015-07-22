class IssueTemplatesController < ApplicationController
  unloadable
  include RedmineIssueTemplates::TemplateOrdering

  include IssueTemplatesHelper
  helper :issues
  include IssuesHelper
  menu_item :issues

  before_filter :find_project_by_project_id, :authorize, :find_user
  before_filter :find_object, :only => [:show, :edit, :update, :destroy]

  def index
    tracker_ids = IssueTemplate.where('project_id = ?', @project.id).pluck(:tracker_id)

    @template_map = Hash::new
    tracker_ids.each do |tracker_id|
      templates = IssueTemplate.
        where('project_id = ? AND tracker_id = ?',
              @project.id, tracker_id).
        order('position')
      if templates.any?
        @template_map[Tracker.find(tracker_id)] = templates
      end
    end

    @issue_templates = IssueTemplate.where('project_id = ?',
                          @project.id).order('position')

    @setting = IssueTemplateSetting.find_or_create(@project.id)
    inherit_template = @setting.enabled_inherit_templates?
    @inherit_templates = []

    project_ids = inherit_template ? @project.ancestors.collect(&:id) : [@project.id]
    if inherit_template
      # keep ordering
      used_tracker_ids = @project.trackers.pluck(:tracker_id)

      project_ids.each do |i|
        @inherit_templates.concat(IssueTemplate.where('project_id = ? AND enabled = ?
          AND enabled_sharing = ? AND tracker_id IN (?)', i, true, true, used_tracker_ids).order('position'))
      end
    end

    @globalIssueTemplates = GlobalIssueTemplate.joins(:projects).where(["projects.id = ?", @project.id]).order('position')

    render :layout => !request.xhr?
  end

  def show
  end

  def new
    @issue_template ||= IssueTemplate.new(:author => @user, :project => @project)
  end

  def create
    new
    @issue_template.safe_attributes = params[:issue_template]
    if @issue_template.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_issue_template_path(@project, @issue_template)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @issue_template.safe_attributes = params[:issue_template]
    if @issue_template.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_issue_template_path(@project, @issue_template)
    end
  end

  def destroy
    if @issue_template.destroy
      flash[:notice] = l(:notice_successful_delete)
      redirect_to project_issue_templates_path(@project)
    end
  end

  # load template description
  def load
    @issue_template = if 'global' == params[:template_type]
      GlobalIssueTemplate.find(params[:issue_template])
    else
      IssueTemplate.find(params[:issue_template])
    end
    render :text => @issue_template.to_json(:root => true)
  end

  # update pulldown
  def set_pulldown
    @tracker = Tracker.find(params[:issue_tracker_id])
    @grouped_options = []
    group = []
    @default_template = nil
    @setting = IssueTemplateSetting.find_or_create(@project.id)
    inherit_template = @setting.enabled_inherit_templates?

    project_ids = inherit_template ? @project.ancestors.collect(&:id) : [@project.id]
    issue_templates = IssueTemplate.where('project_id = ? AND tracker_id = ? AND enabled = ?',
                                          @project.id, @tracker.id, true).order('position')

    project_default_template = IssueTemplate.where('project_id = ? AND tracker_id = ? AND enabled = ?
                                     AND is_default = ?',
                                                  @project.id, @tracker.id, true, true).first

    unless project_default_template.blank?
       @default_template = project_default_template
    end

    if issue_templates.size > 0
      issue_templates.each { |x| group.push([x.title, x.id]) }
    end

    if inherit_template
      inherit_templates = []

      # keep ordering of project tree
       # TODO: Add Test code.
       project_ids.each do |i|
        inherit_templates.concat(IssueTemplate.where('project_id = ? AND tracker_id = ? AND enabled = ?
          AND enabled_sharing = ?', i, @tracker.id, true, true).order('position'))
      end

      if inherit_templates.any?
        inherit_templates.each do |x|
          group.push([x.title, x.id, {:class => "inherited"}])
          if x.is_default == true
             if project_default_template.blank?
              @default_template = x
            end
          end
        end
      end
    end

    @globalIssueTemplates = GlobalIssueTemplate.joins(:projects).where(["tracker_id = ? AND projects.id = ?",
                                                                        @tracker.id, @project.id]).order('position')


    if @globalIssueTemplates.any?
      @globalIssueTemplates.each do |x|
        group.push([x.title, x.id, {:class => "global"}])
        # Using global template as default template is now disabled.
        # if x.is_default == true
        #   if project_default_template.blank?
        #     @default_template = x
        #   end
        # end
      end
    end

    @grouped_options.push([@tracker.name, group]) if group.any?
    render :action => "_template_pulldown", :layout => false
  end

  # preview
  def preview
    @text = (params[:issue_template] ? params[:issue_template][:description] : nil)
    @issue_template = IssueTemplate.find(params[:id]) if params[:id]
    render :partial => 'common/preview'
  end


  private
  def find_user
    @user = User.current
  end

  def find_object
    @issue_template = IssueTemplate.find(params[:id])
  end

  def find_project
    @project = Project.find(params[:project_id])
  end

end

