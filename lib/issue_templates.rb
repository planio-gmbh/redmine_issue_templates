require 'issue_templates/issues_hook'

module IssueTemplates
  def self.setup
    ProjectsController.class_eval do
      helper IssueTemplates::ProjectSettingsTabs
    end
  end

  def self.template_select_options(project, issue)

    got_default = false
    options = all_templates.map do |tpl|
      arr = [ "#{GlobalIssueTemplate === tpl ? "global-" : "project-"}-#{tpl.id}", tpl.title, (!got_default && tpl.is_default) ]
      got_default |= tpl.is_default
      arr
    end
  end

  def self.checklist_enabled?
    Redmine::Plugin.registered_plugins.keys.include? :redmine_checklists
  rescue
    false
  end

  def self.apply_all_projects?
    settings['apply_global_template_to_all_projects'].to_s == 'true'
  end

  def self.settings
    Setting.plugin_redmine_issue_templates
  end

end
