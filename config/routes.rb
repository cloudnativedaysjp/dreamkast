Rails.application.routes.draw do
  root 'home#show', event: 'cndt2020'
  get '/home#show' => redirect('/cndt2020')

  # Auth
  get 'auth/auth0/callback' => 'auth0#callback'
  get 'auth/failure' => 'auth0#failure'
  get 'logout' => 'logout#logout'

  # Admin
  get 'admin' => 'admin#show'
  get 'admin/debug' => 'admin#debug'
  get 'admin/accesslog' => 'admin#accesslog'
  get 'admin/users' => 'admin#users'
  get 'admin/statistics' => 'admin#statistics'
  get 'admin/export_statistics' => 'admin#export_statistics'
  delete 'admin/destroy_user' => 'admin#destroy_user'
  namespace :admin do
    resources :sponsors, only: [:index, :show, :edit, :update]
    resources :booths, only: [:index, :show]
    resources :conferences, only: [:index, :show, :edit, :update]
    resources :speakers, only: [:index, :edit, :update]
    post 'bulk_insert_speakers' => 'speakers#bulk_insert_speakers'
    get 'export_speakers' => 'speakers#export_speakers'
    resources :talks, only: [:index]
    put 'talks' => 'talks#update_talks'
    post 'bulk_insert_talks' => 'talks#bulk_insert_talks'
    post 'bulk_insert_talks_speaker' => 'talks#bulk_insert_talks_speaker'
    resources :tracks, only: [:index]
    put 'tracks' => 'tracks#update_tracks'
    resources :attachments, only: [:show]
  end

  scope ":event" do
    post 'auth/auth0' => redirect('/auth/auth0')
    resources :speakers, only: [:index, :show]
    resources :talks, only: [:show]
    get 'timetables' => 'timetable#index'
    get 'timetables/:date' => 'timetable#index'
    get 'dashboard' => 'tracks#waiting'
    get 'tracks/blank' => 'tracks#blank'
    get 'contents' => 'contents#index'

    resources :tracks, only: [:index, :show]
    get 'registration' => 'profiles#new'
    get '/' => 'event#show'
    get 'privacy' => 'event#privacy'
    get 'coc' => 'event#coc'

    resources :booths, only: [:index, :show]
    resources :attachments, only: [:show]

    # Profile
    resources :profiles, only: [:new, :edit, :update, :destroy, :create]
    namespace :profiles do
      post 'talks', to: 'talks#create'
    end
    get 'profiles/new', to: 'profiles#new'
    post 'profiles', to: 'profiles#create'
    post 'profiles/:id', to: 'profiles#edit'
    put 'profiles', to: 'profiles#update'
    delete 'profiles', to: 'profiles#destroy'
    get 'profiles', to: 'profiles#edit'
    get 'profiles/edit', to: 'profiles#edit'

    delete 'profiles/:id', to: 'profiles#destroy_id'
    put 'profiles/:id/role', to: 'profiles#set_role'
  end

  get '*path', controller: 'application', action: 'render_404'
end