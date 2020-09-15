require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TemplateOptionsForIssueTest < ActiveSupport::TestCase
  fixtures :issue_templates, :projects, :users, :trackers

  TemplateOptionsForIssue = IssueTemplates::TemplateOptionsForIssue

  test "should generate options for project and tracker" do
    assert options = TemplateOptionsForIssue.(project_id: 1, tracker_id: 1)
    assert_equal 3, options.size
    assert o = options.first
    assert_equal 'title1', o.text
    assert_equal 'project-1', o.value
    refute o.is_default

    assert o = options.last
    assert_equal 'global_title1', o.text
    assert_equal 'global-1', o.value
    refute o.is_default
  end

  test "should only pick one default" do
    IssueTemplate.update_all is_default: true
    GlobalIssueTemplate.update_all is_default: true
    assert options = TemplateOptionsForIssue.(project_id: 1, tracker_id: 1)
    assert_equal [true, false, false], options.map(&:is_default)
  end
end

