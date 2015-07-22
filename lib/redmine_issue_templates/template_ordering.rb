module RedmineIssueTemplates
  module TemplateOrdering
    extend ActiveSupport::Concern

    [:to_top, :higher, :lower, :to_bottom].each do |where|
      define_method "move_#{where}" do
        find_object.send "move_#{where}"
        respond_to do |format|
          format.html { redirect_to :action => 'index' }
          format.xml  { head :ok }
        end
      end
    end

  end
end
