module IssueTemplates
  class TemplateOptionsForIssue
    def initialize(project_id:, tracker_id:)
      @project_id = project_id
      @tracker_id = tracker_id
    end

    def self.call(*_)
      new(*_).call
    end

    Option = Struct.new(:text, :value, :is_default)

    def call
      got_default = false
      all_templates.map do |tpl|
        arr = [
          tpl.title,
          "#{GlobalIssueTemplate === tpl ? "global" : "project"}-#{tpl.id}",
          (!got_default && tpl.is_default)
        ]
        got_default |= tpl.is_default
        Option.new(*arr)
      end
    end

    private

    def all_templates
      ProjectTemplates.new(project_id: @project_id, tracker_id: @tracker_id).all
    end
  end
end
