Rails.application.routes.draw do

  post 'users/create_user', to: 'users#create_user'
  get 'users/fetch_users', to: 'users#fetch_users'
  post 'users/update_user_profile', to: 'users#update_user_profile'

  post 'auth/login', to: 'auth#login'
  post 'auth/logout', to: 'auth#logout'

  post 'groups/create_group', to: 'groups#create'
  get 'groups/fetch_groups', to: 'groups#fetch_groups'
  post 'groups/remove_users', to: 'groups#remove_users'
  post 'groups/delete_group', to: 'groups#delete_group'
  get 'groups/user_wise_expense_overview', to: 'groups#get_group_expense_overview'

  post 'expenses/add_group_expense', to: 'expenses#add_group_expense'
  get 'expenses/get_group_expense_details', to: 'expenses#get_group_expense_details'
  post 'expenses/update_group_expense', to: 'expenses#update_group_expense'
  post 'expenses/delete_group_expense', to: 'expenses#delete_group_expense'

  post 'expenses/add_personal_expense', to: 'expenses#add_personal_expense'
  post 'expenses/update_personal_expense', to: 'expenses#update_personal_expense'
  post 'expenses/delete_personal_expense', to: 'expenses#delete_personal_expense'


  get 'expense_history/personal_expense_history', to: 'expense_history#personal_expense_history'
  get 'expense_history/group_expense_history', to: 'expense_history#group_expense_history'
end
