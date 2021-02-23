class AddObsolescenceDateToHrProfiles < ActiveRecord::Migration
def self.up
    add_column :hr_profiles, :obsolescence_date, :date
end

  def self.down
    remove_column :hr_profiles, :obsolescence_date
  end
end