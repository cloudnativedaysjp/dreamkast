Rails.application.routes.draw do
  resources :speakers
  resources :talks
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
  resources :profiles, only: [:new, :edit, :update, :destroy, :create]
  get 'profiles/edit', 'profiles#edit'
end