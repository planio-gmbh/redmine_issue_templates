module IssueTemplatesHelper
  def template_target_trackers(project, issue_template)
    trackers = project.trackers
    trackers |= [issue_template.tracker] unless issue_template.tracker.blank?
    trackers.collect { |obj| [obj.name, obj.id] }
  end

  def options_for_template_pulldown(options)
    safe_join options.map do |option|
      text = option.try(:name).to_s
      content_tag_string(:option, text, option, true)
    end
  end

  def template_url(template)
    template.is_a?(GlobalIssueTemplate) ?
      global_issue_template_path(template) :
      project_issue_template_path(template.project, template)
  end

  def template_edit_link(template)
    url = template.is_a?(GlobalIssueTemplate) ?
      edit_global_issue_template_path(template) :
      edit_project_issue_template_path(template.project, template)
    link_to l(:button_edit), url, class: 'icon icon-edit'
  end

  def can_show_template?(template, user: User.current)
    user.admin? or
      template.is_a?(IssueTemplate) && user.allowed_to?(:show_issue_templates, template.project)
  end

  def can_edit_template?(template, user: User.current)
    user.admin? or
      template.is_a?(IssueTemplate) && user.allowed_to?(:edit_issue_templates, template.project)
  end
end
