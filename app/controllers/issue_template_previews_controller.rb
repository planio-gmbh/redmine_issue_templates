class IssueTemplatePreviewsController < ApplicationController
  def create
    @text = if params[:template]
              params[:template][:description]
            elsif params[:settings]
              params[:settings][:help_message]
            end
    render partial: 'common/preview'
  end
end

