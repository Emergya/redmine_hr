class HrProfile < ActiveRecord::Base
	has_many :costs, class_name: "HrProfilesCost", foreign_key: "hr_profile_id", :dependent => :destroy
	has_many :user_profiles, class_name: "HrUserProfile", foreign_key: "hr_profile_id", :dependent => :destroy
	belongs_to :category, class_name: "HrProfilesCategory", foreign_key: "hr_profiles_category_id"
	has_many :users, -> { where "hr_user_profiles.end_date is ?", nil}, :through => :user_profiles
	has_many :time_entries, dependent: :nullify

	validates_presence_of :name
  validates_length_of :name, :maximum => 20

  after_create :create_costs

  scope :category, -> (id) { where(hr_profiles_category_id: id) }

	def cost_on(year)
		begin
			if costs.where(year: year).present?
				costs.where(year: year).first.hourly_cost
			else
				costs.where("year <= ?", year).order('year DESC').first.hourly_cost
			end
		rescue
			HrProfilesCost::DEFAULT_HOURLY_COST
		end
	end

	def to_s
		name
	end

	private
	def create_costs
		HrProfilesCost.years.each do |year|
			costs << HrProfilesCost.new(year: year, hourly_cost: HrProfilesCost::DEFAULT_HOURLY_COST)
		end
	end
end
