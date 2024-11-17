Rails.application.routes.draw do
  unless Rails.env.development? || Rails.env.test? || ENV['AWS_ACCESS_KEY_ID']
    mount Shrine.uppy_s3_multipart(:video_file) => '/s3/multipart'
  end

  root 'home#show'

  # Auth
  get 'auth/auth0/callback' => 'auth0#callback'
  get 'auth/failure' => 'auth0#failure'
  get 'auth/login' => 'auth0#login'
  get 'logout' => 'logout#logout'

  namespace 'api' do
    namespace 'v1' do
      get ':event/my_profile' => 'profiles#my_profile'
      resources :conferences, only: [:index, :show], path: 'events'
      resources :talks, only: [:index, :show, :update]
      resources :proposals, only: [:index]
      resources :speakers, only: [:index]
      resources :tracks, only: [:index, :show]
      resources :streamings, only: [:index]
      resources :sponsors, only: [:index]
      resources :speakers, only: [:index, :show]
      resources :chat_messages, only: [:index, :create, :update]
      resources :debug, only: [:index]
      resources :check_in_conferences, only: [:create], path: 'check_in_events'
      resources :check_in_talks, only: [:create]
      resources :print_node_printers, only: [:index]
      namespace 'talks' do
        get ':id/video_registration' => 'video_registration#show'
        put ':id/video_registration' => 'video_registration#update'
      end
    end
  end

  scope ':event' do
    post 'auth/auth0' => redirect('/auth/auth0')

    # EntrySheetForPrint
    get 'entry_sheet' => 'entry_sheet#show'

    # Admin
    get 'admin' => 'admin#show'
    get 'admin/debug' => 'admin#debug'
    get 'admin/chat' => 'admin#chat'
    get 'admin/statistics' => 'admin#statistics'
    get 'admin/export_statistics' => 'admin#export_statistics'
    delete 'admin/destroy_user' => 'admin#destroy_user'
    namespace :admin do
      get 'users' => 'profiles#index'
      resources :profiles
      get 'entry_sheet' => 'profiles#entry_sheet'
      resources :check_ins, only: [:index, :create, :destroy]
      resources :admin_profiles, only: [:edit, :update]
      resources :sponsors, only: [:index, :new, :create, :show, :edit, :update, :destroy]
      resources :conferences, only: [:index, :show, :edit, :update] do
        post 'add_link' => 'conferences#add_link'
      end
      resources :speakers, only: [:index, :edit, :update]
      get 'export_speakers' => 'speakers#export_speakers'
      get 'export_profiles' => 'profiles#export_profiles'
      get 'speaker_check_in_statuses' => 'speakers#check_in_statuses'
      resources :check_in_events, only: [:create, :destroy]
      delete 'check_in_events' => 'check_in_events#destroy_all'
      resources :talks, only: [:index]
      resources :rooms, only: [:index, :update]
      put 'rooms' => 'rooms#update'
      resources :proposals, only: [:index]
      resources :videos, only: [:index]
      resources :timetables, only: [:index]
      resource :timetable, only: [:update]
      resources :announcements
      resources :speaker_announcements
      resources :streamings
      resources :stamp_rally_check_points do
        patch :reorder, on: :member
      end
      resources :stamp_rally_configures
      resources :qr_code_for_stamp_rallies, only: [:show]
      post 'create_aws_resources' => 'streamings#create_aws_resources'
      post 'delete_aws_resources' => 'streamings#delete_aws_resources'
      post 'start_media_live_channel' => 'media_live_channel#start_channel'
      post 'stop_media_live_channel' => 'media_live_channel#stop_channel'

      post 'publish_timetable' => 'timetables#publish'
      post 'close_timetable' => 'timetables#close'
      get 'preview_timetable' => 'timetables#preview'
      put 'talks' => 'talks#update_talks'
      post 'start_on_air' => 'talks#start_on_air'
      post 'stop_on_air' => 'talks#stop_on_air'
      put 'proposals' => 'proposals#update_proposals'
      resources :tracks, only: [:index]
      put 'tracks' => 'tracks#update_tracks'
      post 'update_offset' => 'tracks#update_offset'
      resources :attachments, only: [:show]
      get 'team' => 'teams#show'
      put 'team' => 'teams#update'

      resources :harvest_jobs
    end

    get '/team' => 'teams#show'

    get '/speakers/entry' => 'speaker_dashboard/speakers#new'
    get '/speakers/guidance' => 'speaker_dashboard/speakers#guidance'
    get '/speaker_dashboard' => 'speaker_dashboards#show'
    namespace :speaker_dashboard do
      resources :speakers, only: [:new, :edit, :create, :update]
      resources :video_registrations, only: [:new, :create, :edit, :update]
    end
    resources :speaker_invitations, only: [:index, :new, :create]
    resources :speaker_invitation_accepts, only: [:index, :new, :create]
    get '/speaker_invitation_accepts/invite' => 'speaker_invitation_accepts#invite'
    resources :stamp_rally_check_ins, only: [:index, :new, :create]

    namespace :sponsor_dashboards do
      get '/login' => 'sponsor_dashboards#login'
      get ':sponsor_id' => 'sponsor_dashboards#show'
      scope ':sponsor_id' do
        resources :sponsor_profiles, only: [:new, :edit, :create, :update]
        resources :speakers, only: [:new, :edit, :create, :update]
      end
    end

    resources :talks, only: [:show, :index]
    resources :proposals, only: [:show, :index]
    get 'timetables' => 'timetable#index'
    get 'timetables/:date' => 'timetable#index'
    get 'dashboard' => 'attendee_dashboards#show'
    get 'tracks/blank' => 'tracks#blank'
    get 'kontest' => 'contents#kontest'
    get 'discussion' => 'contents#discussion'
    get 'hands-on' => 'contents#hands_on'
    get 'job-board' => 'contents#job_board'
    get 'o11y' => 'contents#o11y'
    get 'attendees' => 'attendees#index'
    get 'community_lt' => 'contents#community_lt'
    get 'yurucafe' => 'contents#yurucafe'
    get 'stamprally' => 'contents#stamprally'

    resources :tracks, only: [:index, :show]
    get 'registration' => 'profiles#new'
    get '/' => 'event#show'
    get 'privacy' => 'event#privacy'
    get 'coc' => 'event#coc'

    resources :attachments, only: [:show]

    # Profile
    resources :profiles, only: [:new, :edit, :update, :create]
    namespace :profiles do
      post 'talks', to: 'talks#create'
    end
    get 'profiles/calendar', to: 'profiles#calendar'
    post 'profiles/:id', to: 'profiles#edit'
    put 'profiles', to: 'profiles#update'
    delete 'profiles', to: 'profiles#destroy'
    get 'profiles', to: 'profiles#edit'
    get 'profiles/edit', to: 'profiles#edit'
    get 'profiles/checkin', to: 'profiles#checkin'
    get 'profiles/view_qr' => 'profiles#view_qr'
    resources :public_profiles


    delete 'profiles/:id', to: 'profiles#destroy_id'
    put 'profiles/:id/role', to: 'profiles#set_role'
    resources :links, only: [:index]

    get 'preparation' => 'event#preparation'
  end

  mount AvatarUploader.upload_endpoint(:cache) => '/upload/avatar'
  get '*path', controller: 'application', action: 'render_404'
end
