module Concerns
  module IssueTemplatesCommon
    def checklists
      template_params[:checklists].presence || {}
    end
    private :checklists
  end
end
