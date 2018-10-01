module Hr
  module IssueCustomFieldPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        has_and_belongs_to_many :projects, :join_table => "#{table_name_prefix}custom_fields_projects#{table_name_suffix}", :foreign_key => "custom_field_id", :after_add => :add_project
        has_and_belongs_to_many :trackers, :join_table => "#{table_name_prefix}custom_fields_trackers#{table_name_suffix}", :foreign_key => "custom_field_id", :after_add => :add_tracker
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def add_project(project)
        if self.id.to_s == Setting.plugin_redmine_hr['issue_effort_cost_field']
          project.issues.where("tracker_id IN (?)", self.trackers.map(&:id)).map(&:update_effort_cost)
        end
      end

      def add_tracker(tracker)
        if self.id.to_s == Setting.plugin_redmine_hr['issue_effort_cost_field']
          tracker.issues.where("project_id IN (?)", self.projects.map(&:id)).map(&:update_effort_cost)
        end
      end
    end
  end
end

ActionDispatch::Callbacks.to_prepare do
  # use require_dependency if you plan to utilize development mode
  require_dependency 'custom_field'
  require_dependency 'issue_custom_field'
  IssueCustomField.send(:include, Hr::IssueCustomFieldPatch)
end
