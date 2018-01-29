require 'hr/application_helper_patch'
require 'hr/users_helper_patch'
require 'hr/user_patch'
require 'hr/time_entries_patch'
require 'hr/time_entry_reports_common_patch'

Redmine::Plugin.register :redmine_hr do
  Rails.configuration.after_initialize do
    locale = if Setting.table_exists?
               Setting.default_language
             else
               'en'
             end
    I18n.with_locale(locale) do
      name I18n.t :'hr.plugin_name'
      description I18n.t :'hr.plugin_description'
      author 'Emergya Consultoría'
      version '0.0.1'
    end
  end

  permission :view_profiles, { :user => [:show] }

  menu :admin_menu, :'hr.label_cost_history', { :controller => 'hr_profiles_costs', :action => 'index' },
       :html => { :class => 'issue_statuses' },
       :caption => :'hr.label_cost_history'

  menu :admin_menu, :'hr.label_profile_management', { :controller => 'hr_profiles', :action => 'index' },
       :html => { :class => 'issue_statuses' },
       :caption => :'hr.label_profile_management'

  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'     
end
