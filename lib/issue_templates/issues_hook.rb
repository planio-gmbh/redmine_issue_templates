# frozen_string_literal: true

module IssueTemplates
  class IssuesHook < Redmine::Hook::ViewListener
    include IssuesHelper

    CONTROLLERS = %w[
      IssuesController IssueTemplatesController ProjectsController
      GlobalIssueTemplatesController SettingsController
    ].freeze

    ACTIONS = %w[new create show].freeze

    def view_layouts_base_html_head(context = {})
      o = stylesheet_link_tag('issue_templates', plugin: 'redmine_issue_templates')
      if CONTROLLERS.include?(context[:controller].class.name)
        o << javascript_include_tag('issue_templates', plugin: 'redmine_issue_templates')
      end
      o
    end

    def view_issues_form_details_top(context = {})
      issue      = context[:issue]
      project    = context[:project]
      parameters = context[:request].parameters

      return unless User.current.allowed_to?(:show_issue_templates, project||issue.project)

      return if issue.persisted? || issue.tracker_id.blank?
      return if parameters[:copy_from].present?

      project_id = project&.id || issue.project_id
      return unless ACTIONS.include?(parameters[:action]) && project_id.present?

      trigger = parameters[:form_update_triggered_by].presence
      new_or_tracker_changed = trigger.nil? ||
        %w[issue_tracker_id issue_project_id].include?(trigger)

      context[:controller].send(
        :render_to_string,
        partial: 'issue_templates/issue_select_form',
        locals: {
          setting: IssueTemplateSetting.find_or_create(project_id),
          issue: issue,
          new_or_tracker_changed: new_or_tracker_changed,
          project_id: project_id
        }
      )
    end

    render_on :view_issues_sidebar_planning_bottom, partial: 'issue_templates/issue_template_link'
  end
end
