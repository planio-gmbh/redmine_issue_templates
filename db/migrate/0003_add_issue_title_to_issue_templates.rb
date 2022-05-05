class AddIssueTitleToIssueTemplates < ActiveRecord::Migration[4.2]
  def self.up
    add_column :issue_templates, :issue_title, :string
    connection.execute 'update issue_templates set issue_title = title'
  end

  def self.down
    remove_column :issue_templates, :issue_title
  end
end
