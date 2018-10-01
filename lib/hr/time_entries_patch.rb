require_dependency 'time_entry'

module Hr
  module TimeEntryPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        belongs_to :hr_profile
        after_save :update_profile_and_cost
        after_save :update_issue_effort_cost
        after_destroy :update_issue_effort_cost
      end
    end

    module ClassMethods
      def effort_incurred(projects = Project.all.map(&:id), profiles = HrProfile.all.map(&:id)+[nil], start_date = TimeEntry.order(:spent_on).first.spent_on, end_date = TimeEntry.order(:spent_on).last.spent_on)
        projects = [projects] if !projects.is_a?(Array)
        profiles = [profiles] if !profiles.is_a?(Array)
        without_profile = profiles.include?(nil) ? " OR hr_profile_id IS NULL" : ""
        where("project_id IN (?) AND (hr_profile_id IN (?)"+without_profile+") AND spent_on BETWEEN ? AND ?", projects, profiles, start_date, end_date).sum(:hours)
      end

      def cost_incurred(projects = Project.all.map(&:id), profiles = HrProfile.all.map(&:id), start_date = TimeEntry.order(:spent_on).first.spent_on, end_date = TimeEntry.order(:spent_on).last.spent_on)
        projects = [projects] if !projects.is_a?(Array)
        profiles = [profiles] if !profiles.is_a?(Array)
        where("project_id IN (?) AND hr_profile_id IN (?) AND spent_on BETWEEN ? AND ?", projects, profiles, start_date, end_date).sum(:cost)
      end
    end

    module InstanceMethods
      def update_profile_and_cost
        profile_id = (profile = self.user.current_profile(self.spent_on)).present? ?
          profile.id :
          nil

        hourly_cost = (profile_cost = profile.present? ?
          profile.cost_on(self.spent_on.year) :
          HrProfilesCost::DEFAULT_HOURLY_COST)

        set_profile_and_cost(profile_id, hourly_cost)
      end

      def update_issue_effort_cost
        if issue.present?
          issue.update_effort_cost
        end
      end

      def remove_profile_and_cost
        set_profile_and_cost(nil, HrProfilesCost::DEFAULT_HOURLY_COST)
      end

      def set_profile_and_cost(profile_id, hourly_cost)
        self.update_columns(hr_profile_id: profile_id, cost: (self.hours.to_f * hourly_cost.to_f))
      end
    end
  end
end

ActionDispatch::Callbacks.to_prepare do
  TimeEntry.send(:include, Hr::TimeEntryPatch)
end
