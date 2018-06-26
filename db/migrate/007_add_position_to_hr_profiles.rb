class AddPositionToHrProfiles < ActiveRecord::Migration
  def self.up
    add_column :hr_profiles, :position, :integer, :null => false

    HrProfile.all.order("id ASC").each_with_index do |profile, i|
    	profile.update_attribute(:position, i+1)
    end
  end

  def self.down
    remove_column :hr_profiles, :position
  end
end
