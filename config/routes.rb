Rails.application.routes.draw do
  get 'dashboard/show'
  root 'home#show'
  get 'home/show'
  get 'auth/auth0/callback' => 'auth0#callback'
  get 'auth/failure' => 'auth0#failure'
  get 'dashboard' => 'dashboard#show'
  get '/logout' => 'logout#logout'
end