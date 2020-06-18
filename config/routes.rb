Rails.application.routes.draw do
  get 'track/:id' => 'track#show'
  get 'dashboard/show'
  root 'home#show'
  get 'home/show'
  get 'admin' => 'admin#show'
  get 'auth/auth0/callback' => 'auth0#callback'
  get 'auth/failure' => 'auth0#failure'
  get 'dashboard' => 'dashboard#show'
  get '/logout' => 'logout#logout'
  get 'registration' => 'profiles#new'
  resources :profiles
end