resources :hr_profiles
resources :hr_profiles_categories
resources :hr_profiles_costs, only: [:index]

resources :users do
  resources :hr_user_profiles
end

match "hr_profiles_costs/create_year", :to => "hr_profiles_costs#create_year", :via => [:post]
match "hr_profiles_costs/edit_year/:year", :to => "hr_profiles_costs#edit_year", :via => [:get], :as => 'hr_profiles_costs_edit_year'
match "hr_profiles_costs/update_year/:year", :to => "hr_profiles_costs#update_year", :via => [:put], :as => 'hr_profiles_costs_update_year'
match "hr_profiles_costs/destroy_year/:year", :to => "hr_profiles_costs#destroy_year", :via => [:delete]
match "hr_profiles/:id/move", :to => "hr_profiles#move", :via => [:get, :put, :post]
