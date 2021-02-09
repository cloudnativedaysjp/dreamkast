Rails.application.routes.draw do
  root 'home#show'

  # Auth
  get 'auth/auth0/callback' => 'auth0#callback'
  get 'auth/failure' => 'auth0#failure'
  get 'logout' => 'logout#logout'

  namespace 'api' do
    namespace 'v1' do
      resources :conferences, only: [:show], path: "events"
      resources :talks, only: [:index, :show]
      resources :tracks, only: [:index, :show]
      resources :chat_messages, only: [:index, :create]
    end
  end

  scope ":event" do
    post 'auth/auth0' => redirect('/auth/auth0')

    # Admin
    get 'admin' => 'admin#show'
    get 'admin/debug' => 'admin#debug'
    get 'admin/chat' => 'admin#chat'
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
      resources :timetables, only: [:index]
      resource :timetable, only: [:update]
      post 'publish_timetable' => 'timetables#publish'
      post 'close_timetable' => 'timetables#close'
      put 'talks' => 'talks#update_talks'
      post 'bulk_insert_talks' => 'talks#bulk_insert_talks'
      post 'bulk_insert_talks_speaker' => 'talks#bulk_insert_talks_speaker'
      resources :tracks, only: [:index]
      put 'tracks' => 'tracks#update_tracks'
      resources :attachments, only: [:show]
    end

    get '/speakers/entry' => 'speaker_dashboard/speakers#new'
    resources :speakers, only: [:index, :show]
    get '/speaker_dashboard' => 'speaker_dashboards#show'
    namespace :speaker_dashboard do
      resources :speakers, only: [:new, :edit, :create, :update]
    end


    resources :talks, only: [:show, :index]
    get 'timetables' => 'timetable#index'
    get 'timetables/:date' => 'timetable#index'
    get 'dashboard' => 'tracks#waiting'
    get 'tracks/blank' => 'tracks#blank'
    get 'kontest' => 'contents#kontest'
    get 'discussion' => 'contents#discussion'

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
    resources :links, only: [:index]
  end

  get '*path', controller: 'application', action: 'render_404'
end