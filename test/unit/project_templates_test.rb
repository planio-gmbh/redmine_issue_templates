require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ProjectTemplatesTest < ActiveSupport::TestCase
  fixtures :issue_templates, :projects, :users, :trackers

  ProjectTemplates = IssueTemplates::ProjectTemplates

  setup do
  end

  test "should find templates for project and tracker" do
    tfi = ProjectTemplates.new(project_id: 1, tracker_id: 1)
    assert templates = tfi.issue_templates
    assert_equal [1, 4], templates.map(&:id)
    assert inherited = tfi.inherited_templates
    assert inherited.none?
    assert global = tfi.global_templates
    assert_equal [1], global.map(&:id)

    assert all = tfi.all
    assert_equal [templates, inherited, global].flatten, all
  end

  test "should find inherited template" do
    refute IssueTemplates.apply_all_projects?
    IssueTemplateSetting.find(3).update_column :inherit_templates, true
    tfi = ProjectTemplates.new(project_id: 3, tracker_id: 1)

    assert templates = tfi.issue_templates
    assert_equal [6], templates.map(&:id)
    assert inherited = tfi.inherited_templates
    assert_equal [1], inherited.map(&:id)
  end

  test "should find orphaned templates for project" do
    Project.find(1).update_attribute :tracker_ids, [1]
    pt = ProjectTemplates.new project_id: 1
    assert orphaned = pt.orphaned
    assert_equal [2, 3], orphaned.map(&:id)
  end

  test "should find global template for project with global_all_projects" do
    with_settings("plugin_redmine_issue_templates" => {'apply_global_template_to_all_projects' => true }) do
      Project.find(1).update_attribute :tracker_ids, [1]
      IssueTemplate.where(tracker_id: 1, project_id: 1).update_all enabled: false
      pt = ProjectTemplates.new project_id: 1, tracker_id: 1
      assert globals = pt.global_templates
      assert globals.present?
    end
  end
end
