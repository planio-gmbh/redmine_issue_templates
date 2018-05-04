module IssueTemplates
  module ProjectSettingsTabs
    def project_settings_tabs
      super.tap do |tabs|
        if User.current.allowed_to?(:manage_issue_templates, @project) ||
          User.current.allowed_to?(:edit_issue_templates, @project)

          tabs << {
            name: 'issue_templates',
            partial: 'issue_templates_settings/show',
            label: :project_module_issue_templates
          }
        end
      end
    end
  end
end
