Rails.application.routes.draw do
  resources :posts
  root to: 'home#index'
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  }
end
