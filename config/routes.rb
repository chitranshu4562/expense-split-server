Rails.application.routes.draw do

  post 'users/create_user', to: 'users#create_user'
  get 'users/fetch_users', to: 'users#fetch_users'

  post 'auth/login', to: 'auth#login'
  post 'auth/logout', to: 'auth#logout'

  post 'groups/create_group', to: 'groups#create'
  post 'groups/remove_users', to: 'groups#remove_users'
  get 'groups/user_wise_expense_overview', to: 'groups#get_group_expense_overview'

  post 'expenses/add_group_expense', to: 'expenses#add_group_expense'
end
