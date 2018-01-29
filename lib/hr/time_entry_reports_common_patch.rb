require_dependency 'time_entry_reports_controller' if File.exists?("#{Rails.root}/app/controllers/time_entry_reports_controller.rb")
require_dependency 'timelog_controller' if File.exists?("#{Rails.root}/app/controllers/timelog_controller.rb")
require_dependency 'redmine/helpers/time_report' if File.exists?("#{Rails.root}/lib/redmine/helpers/time_report.rb")

# Patches Redmine's TimeEntryReportsController dinamically. Adds an option "Role" to the list of available criterias
# for the time entries report
module HR
  module TimeEntryReportsCommonPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        if File.exists?("#{Rails.root}/lib/redmine/helpers/time_report.rb")
          alias_method_chain :load_available_criteria, :profile
        else
          before_filter :load_profile_criteria, :only => [:report]
        end
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def load_profile_criteria
        @available_criteria['profile'] = {:sql => "Role",
                                           :label => :label_profile}
      end

      def load_available_criteria_with_profile
        @available_criteria = {}
        @available_criteria = load_available_criteria_without_profile

        if User.current.allowed_to?(:view_profiles, nil, {:global => true})
          @available_criteria['profile'] = {:joins => :hr_profile, #"LEFT JOIN #{HrProfile.table_name} ON #{HrProfile.table_name}.id = #{TimeEntry.table_name}.hr_profile_id SELECT",
                                            :sql => "#{HrProfile.table_name}.name",
                                            :label => :label_profile}
        end                                        
        @available_criteria
      end
    end
  end
end

ActionDispatch::Callbacks.to_prepare do
  TimeEntryReportsController.send(:include, HR::TimeEntryReportsCommonPatch) if File.exists?("#{Rails.root}/app/controllers/time_entry_reports_controller.rb")
  # For Redmine >= 1.4
  Redmine::Helpers::TimeReport.send(:include, HR::TimeEntryReportsCommonPatch) if File.exists?("#{Rails.root}/lib/redmine/helpers/time_report.rb")
end
