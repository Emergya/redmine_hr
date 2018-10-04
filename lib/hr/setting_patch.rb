module Hr
  module SettingPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        after_save :change_issue_effort_cost_field

      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def change_issue_effort_cost_field
        if self.name == 'plugin_redmine_hr' and self.value['issue_effort_cost_field'].present? and (self.value_was.blank? or (self.value['issue_effort_cost_field'] != self.value_was['issue_effort_cost_field']))
          cf = IssueCustomField.find(self.value['issue_effort_cost_field'])
          Issue.where("project_id IN (?) AND tracker_id IN (?)", cf.projects.map(&:id), cf.trackers.map(&:id)).map(&:update_effort_cost)
        end
      end
    end
  end
end

ActionDispatch::Callbacks.to_prepare do
  # use require_dependency if you plan to utilize development mode
  require_dependency 'setting'
  Setting.send(:include, Hr::SettingPatch)
end
