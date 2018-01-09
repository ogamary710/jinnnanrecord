Rails.application.routes.draw do
  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 'tests/index'

  get 'tests/show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
