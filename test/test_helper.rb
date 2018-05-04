require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

begin
#  require 'shoulda'
rescue LoadError => ex
  puts <<-"EOS"
  This test should be called only for redmine issue template test.
    Test exit with LoadError --  #{ex.message}
  Please move redmine_issue_templates/Gemfile.local to redmine_issue_templates/Gemfile
  and run bundle install if you want to to run tests.
  EOS
  exit
end

ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/',
                                         %i[issue_templates issue_template_settings
                                            global_issue_templates global_issue_templates_projects])
