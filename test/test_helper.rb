require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/',
                                         %i[issue_templates issue_template_settings
                                            global_issue_templates global_issue_templates_projects])
