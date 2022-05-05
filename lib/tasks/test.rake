namespace :redmine_issue_templates do
  desc 'Run spec for redmine_issue_template plugin'
  task :spec do |task_name|
    next unless ENV['RAILS_ENV'] == 'test' && task_name.name == 'redmine_issue_templates:spec'
    begin
      require 'rspec/core'
      path = 'plugins/redmine_issue_templates/spec/'
      options = ['-I plugins/redmine_issue_templates/spec']
      options << '--format'
      options << 'documentation'
      options << path
      RSpec::Core::Runner.run(options)
    rescue LoadError => ex
      puts "This task should be called only for redmine issue template spec. #{ex.message}"
    end
  end
end
