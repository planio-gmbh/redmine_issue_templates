module IssueTemplates
  class ProjectTemplates
    def initialize(project_id:, tracker_id: nil)
      @project_id = project_id
      @tracker_id = tracker_id
    end

    def all
      [ issue_templates, inherited_templates, global_templates ].flatten
    end

    def issue_templates(only_enabled: true)
      @issue_templates ||= find_issue_templates(only_enabled)
    end

    def find_issue_templates(only_enabled)
      scope = only_enabled ? IssueTemplate.enabled : IssueTemplate.all
      if @tracker_id
        scope = scope.search_by_tracker @tracker_id
      end
      if @project_id
        scope = scope.search_by_project @project_id
      end
      scope.sorted
    end

    def orphaned
      project = Project.find @project_id
      IssueTemplate.where(project_id: @project_id).
        where.not(tracker_id: project.tracker_ids)
    end

    def inherited_templates
      @inherited_templates ||= setting.get_inherit_templates(@tracker_id)
    end

    def global_templates
      # if we have project or inherited project templates for the tracker, no
      # global trackers are shown when apply_all_projects is true.
      @global_templates ||= if IssueTemplates.apply_all_projects? && (inherited_templates.present? || issue_templates.present?)
          GlobalIssueTemplate.none
        else
          scope = GlobalIssueTemplate.enabled
          if @project_id and not IssueTemplates.apply_all_projects?
            scope = scope.search_by_project(@project_id)
          end
          if @tracker_id
            scope = scope.search_by_tracker(@tracker_id)
          end
          scope.sorted
        end
    end

    def setting
      @setting ||= IssueTemplateSetting.find_or_create(@project_id)
    end
  end
end

