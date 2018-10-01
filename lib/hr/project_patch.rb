module Hr
  module ProjectPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        has_and_belongs_to_many :issue_custom_fields,
                          lambda {order("#{CustomField.table_name}.position")},
                          :class_name => 'IssueCustomField',
                          :join_table => "#{table_name_prefix}custom_fields_projects#{table_name_suffix}",
                          :association_foreign_key => 'custom_field_id',
                          :after_add => :update_issue_effort_cost_field

      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def update_issue_effort_cost_field(custom_field)
        if custom_field.present? and custom_field.id.to_s == Setting.plugin_redmine_hr['issue_effort_cost_field']
          self.issues.where("tracker_id IN (?)", custom_field.trackers.map(&:id)).map(&:update_effort_cost)
        end
      end
    end
  end
end

ActionDispatch::Callbacks.to_prepare do
  # use require_dependency if you plan to utilize development mode
  require_dependency 'project'
  Project.send(:include, Hr::ProjectPatch)
end
