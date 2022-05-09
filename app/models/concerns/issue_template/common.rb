module Concerns
  module IssueTemplate
    module Common
      extend ActiveSupport::Concern

      #
      # Common scope both global and project scope template.
      #
      included do
        belongs_to :author, class_name: 'User', foreign_key: 'author_id'
        belongs_to :tracker
        before_save :check_default

        before_destroy :confirm_disabled

        validates :title, presence: true
        validates :tracker, presence: true

        acts_as_positioned scope: [:tracker_id]

        scope :enabled, -> { where(enabled: true) }
        scope :sorted, -> { order(:position) }
        scope :search_by_tracker, lambda { |tracker_id|
          where(tracker_id: tracker_id) if tracker_id.present?
        }

        scope :is_default, -> { where(is_default: true) }
        scope :not_default, -> { where(is_default: false) }

        scope :orphaned, lambda { |project_id = nil|
          condition = all
          if project_id.present? && try(:name) == 'IssueTemplate'
            condition = condition.where(project_id: project_id)
            ids = Tracker.joins(:projects).where(projects: { id: project_id }).pluck(:id)
          else
            ids = Tracker.pluck(:id)
          end
          condition.where.not(tracker_id: ids)
        }
      end

      #
      # Common methods both global and project scope template.
      #
      def enabled?
        enabled
      end

      def <=>(other)
        position <=> other.position
      end

      def checklist
        return [] if checklist_json.blank?
        begin
          JSON.parse(checklist_json)
        rescue
          []
        end
      end

      def template_json
        template = {}
        template[self.class::Config::JSON_OBJECT_NAME] = generate_json
        template.to_json(root: true)
      end

      def generate_json
        result = attributes
        result[:checklist] = checklist
        result.except('checklist_json')
      end

      def confirm_disabled
        return unless enabled?
        errors.add :base, 'enabled_template_cannot_destroy'
        throw :abort
      end

      def copy_title
        "copy_of_#{title}"
      end

      def copy
        tpl = self.dup
        tpl.title = copy_title
        tpl
      end
    end
  end
end
