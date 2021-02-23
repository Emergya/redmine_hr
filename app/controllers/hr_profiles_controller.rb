class HrProfilesController < ApplicationController
  layout 'admin'
  before_filter :require_admin
  before_filter :get_profile, :only => [:edit, :update, :move, :destroy]

  def index
    @profiles = HrProfile.all.order(:position)
    @categories = HrProfilesCategory.all.order(:id)
  end

  def new
    @profile = HrProfile.new
    @categories = HrProfilesCategory.all
  end

  def create
    @profile = HrProfile.new(profile_params)
    unless HrProfile.first.nil?
      @profile.position = HrProfile.maximum(:position) + 1
    else
      @profile.position = 1
    end
    if @profile.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to hr_profiles_path
    else
      @categories = HrProfilesCategory.all
      render :action => 'new'
    end
  end

  def edit
    @categories = HrProfilesCategory.all
  end

  def update
    if @profile.update_attributes(profile_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to hr_profiles_path(:page => params[:page])
    else
      render :action => 'edit'
    end
  end

  def move
    if params[:hr_profile].present? and params[:hr_profile][:move_to].present?
      case params[:hr_profile][:move_to]
      when "highest"
        profiles = HrProfile.where("id != ?", @profile.id).order("position ASC")
        profiles.each_with_index do |profile, i|
          profile.update_attribute(:position, i+2)
        end
        @profile.update_attribute(:position, 1)
      when "higher"
        options = HrProfile.where("position < ?", @profile.position).order("position DESC")
        if options.present?
          current_position = @profile.position
          @profile.update_attribute(:position, options.first.position)
          options.first.update_attribute(:position, current_position)
        end
      when "lower"
        options = HrProfile.where("position > ?", @profile.position).order("position ASC")
        if options.present?
          current_position = @profile.position
          @profile.update_attribute(:position, options.first.position)
          options.first.update_attribute(:position, current_position)
        end
      when "lowest"
        profiles = HrProfile.where("id != ?", @profile.id).order("position ASC")
        profiles.each_with_index do |profile, i|
          profile.update_attribute(:position, i+1)
        end
        @profile.update_attribute(:position, profiles.count)
      end
    end
    redirect_to hr_profiles_path
  end

  def destroy
    @profile.destroy
    redirect_to hr_profiles_path
  rescue
    flash[:error] = l(:"hr.error_unable_delete_profile")
    redirect_to hr_profiles_path
  end

  private
  def profile_params
    params.require(:hr_profile).permit(:name, :hr_profiles_category_id, :obsolescence_date)
  end

  def get_profile
    if params[:id].present?
      @profile = HrProfile.find(params[:id])
    end
  end
end