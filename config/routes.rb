Rails.application.routes.draw do
  root to: 'home#index'
  resources :posts do
    resources :comments, only: %i[create show destroy]
    resources :likes, only: %i[create destroy]
  end
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  }
end
