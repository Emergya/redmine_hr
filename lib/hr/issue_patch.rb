module Hr
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def update_effort_cost
        cv = get_effort_cost_field
        if cv.present?
          value = get_effort_cost
          value = value.to_s+" €" if cv.custom_field.field_format == 'string'
          cv.update_attribute('value', value)
        end
      end

      def get_effort_cost_field
        if Setting.plugin_redmine_hr.present? and Setting.plugin_redmine_hr['issue_effort_cost_field'].present? and self.tracker.custom_fields.map(&:id).include?(Setting.plugin_redmine_hr['issue_effort_cost_field'].to_i) and self.project.issue_custom_fields.map(&:id).include?(Setting.plugin_redmine_hr['issue_effort_cost_field'].to_i)
          self.custom_values.find_or_create_by(custom_field_id: Setting.plugin_redmine_hr['issue_effort_cost_field'])
        else
          nil
        end
      end

      def get_effort_cost
        self.time_entries.sum(:cost).round(2)
      end
    end
  end
end

ActionDispatch::Callbacks.to_prepare do
  # use require_dependency if you plan to utilize development mode
  require_dependency 'issue'
  Issue.send(:include, Hr::IssuePatch)
end
