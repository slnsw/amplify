Rails.application.routes.draw do

  resources :flags, only: [:index, :show, :create]
  resources :transcript_speaker_edits, only: [:create]
  resources :transcript_edits, only: [:index, :show, :create]
  resources :transcript_files, only: [:index, :show]
  resources :transcripts, only: [:index, :show] do
    member do
      get :facebook_share
    end
  end
  resources :collections, only: [:index, :show]

  mount_devise_token_auth_for 'User',
    at: 'auth',
    controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  # Handle additional providers such as SAML.
  match 'auth/:provider/callback',
    controller: 'users/omniauth_callbacks',
    action: 'redirect_callbacks',
    via: [:post],
    defaults: {
      'namespace_name' => 'omniauth',
      'resource_class' => 'User'
    }

  match 'page/:id' => 'default#index', :via => [:get]
  match 'dashboard' => 'default#index', :via => [:get]
  match 'transcript_lines/:id/resolve' => 'transcript_lines#resolve', :via => [:post]
  match 'search' => 'transcripts#search', :via => [:get]

  # admin
  namespace :admin do
    resources :users, only: [:index, :update]
    resources :transcripts, only: [:index]
    resources :flags, only: [:index]

    get 'cms', to: 'cms#show'
    namespace :cms do
      resources :collections, except: [:delete, :index]
      resources :transcripts, except: [:show, :delete, :index] do
        get "speaker_search", on: :collection
        post "process_transcript", on: :member
      end
    end
  end
  match 'admin' => 'admin/stats#index', :via => [:get], :as => :admin

  # moderator
  namespace :moderator do
    resources :flags, only: [:index]
  end
  match 'moderator' => 'admin/flags#index', :via => [:get], :as => :moderator

  root :to => 'default#index'
end
