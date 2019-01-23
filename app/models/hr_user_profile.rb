class HrUserProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :profile, class_name: "HrProfile", foreign_key: "hr_profile_id"

  validates :start_date, :allow_nil => false,
              :format => {:with => /\d{4}-\d{2}-\d{2}/, :message => :not_a_date }
  validates :end_date, :allow_nil => true,
              :format => {:with => /\d{4}-\d{2}-\d{2}/, :message => :not_a_date }
  validate :overlaps
  validate :end_after_start

  after_create :create_user_profile
  after_update :update_user_profile
  after_destroy :destroy_user_profile

  def overlaps
    overlap = HrUserProfile.where("(? IS NULL OR id != ?) AND user_id = ? AND !((? IS NOT NULL AND start_date > ?) OR (end_date IS NOT NULL AND end_date < ?))", self.id, self.id, self.user_id, self.end_date, self.end_date, self.start_date)
    errors.add(:base, l(:"activerecord.errors.messages.overlap")) if overlap.present?
  end

  def end_after_start
    success = (self.start_date.present? and (self.end_date.nil? or self.end_date > self.start_date))
    errors.add(:base, l(:"activerecord.errors.messages.end_after_start")) if !success
  end

  def profile
    super || HrProfile.new(name: "")
  end

  def time_entries
    TimeEntry.where("user_id = ? AND ((spent_on BETWEEN ? AND ?) OR (spent_on >= ? AND ? is NULL))", self.user_id, self.start_date, self.end_date, self.start_date, self.end_date)
  end

  def create_user_profile
    last_date = (last_time_entry = TimeEntry.order('spent_on DESC').first).present? ? 
      last_time_entry.spent_on :
      Date.today

    hourly_costs = self.profile.present? ? self.profile.costs.inject({}){|h, c| h[c.year] = c.hourly_cost; h} : Hash.new(HrProfilesCost::DEFAULT_HOURLY_COST)

    (self.start_date.year..(self.end_date || last_date).year).each do |year|
      if hourly_costs.keys.blank?
        hourly_cost = HrProfilesCost::DEFAULT_HOURLY_COST
      elsif year > hourly_costs.keys.max
        hourly_cost = hourly_costs[hourly_costs.keys.max]
      elsif year < hourly_costs.keys.min
        hourly_cost = hourly_costs[hourly_costs.keys.min]
      else
        hourly_cost = hourly_costs[year]
      end

      profile_id = self.hr_profile_id.present? ? self.hr_profile_id : "NULL"
      self.time_entries.where(tyear: year).update_all("hr_profile_id = #{profile_id}, cost = (#{hourly_cost} * hours)")
    end
    # self.time_entries.each{|te| te.set_profile_and_cost(self.hr_profile_id, hourly_costs[te.tyear])}
  end

  def destroy_user_profile
    self.time_entries.each(&:remove_profile_and_cost)
  end

  def update_user_profile
    last_date = (last_time_entry = TimeEntry.order('spent_on DESC').first).present? ? 
      last_time_entry.spent_on :
      Date.today
      
    if self.start_date > self.start_date_was
      HrUserProfile.new(user_id: self.user_id, 
        start_date: self.start_date_was, 
        end_date: [self.start_date, (self.end_date_was || last_date)].min)
        .time_entries.each(&:remove_profile_and_cost)
    end

    if (self.end_date || last_date) < (self.end_date_was || last_date)
      HrUserProfile.new(user_id: self.user_id, 
        start_date: [self.start_date_was, (self.end_date || last_date)].max, 
        end_date: (self.end_date_was || last_date))
        .time_entries.each(&:remove_profile_and_cost)
    end

    hourly_costs = self.profile.present? ? self.profile.costs.inject({}){|h, c| h[c.year] = c.hourly_cost; h} : Hash.new(HrProfilesCost::DEFAULT_HOURLY_COST)

    (self.start_date.year..(self.end_date || last_date).year).each do |year|
      if hourly_costs.keys.blank?
        hourly_cost = HrProfilesCost::DEFAULT_HOURLY_COST
      elsif year > hourly_costs.keys.max
        hourly_cost = hourly_costs[hourly_costs.keys.max]
      elsif year < hourly_costs.keys.min
        hourly_cost = hourly_costs[hourly_costs.keys.min]
      else
        hourly_cost = hourly_costs[year]
      end
      profile_id = self.hr_profile_id.present? ? self.hr_profile_id : "NULL"
      self.time_entries.where(tyear: year).update_all("hr_profile_id = #{profile_id}, cost = (#{hourly_cost} * hours)")
    end
    # self.time_entries.each{|te| te.set_profile_and_cost(self.hr_profile_id, hourly_costs[te.tyear])}
  end
end
