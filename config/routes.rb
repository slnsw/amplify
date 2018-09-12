Rails.application.routes.draw do

  namespace :admin do
    resources :institutions do
      resources :transcription_conventions
    end
    resources :pages do
      member do
        post :upload
        delete :delete_upload
      end
    end
    resources :themes, except: [:show]
    resources :app_configs, only: [:edit, :update]
  end
  resources :flags, only: [:index, :show, :create]
  resources :transcript_speaker_edits, only: [:create]
  resources :transcript_edits, only: [:index, :show, :create]
  resources :transcript_files, only: [:index, :show]
  resources :transcripts, only: [:index, :show] do
    member do
      get :facebook_share
    end
  end
  resources :collections, only: [:index, :show] do
    collection do
      post :list
    end
  end

  devise_for :users,
    controllers: {
    sessions: "users/sessions",
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: "users/registrations",
    passwords: "users/passwords"
  }

  match 'page/faq' => 'page#faq', :via => [:get]
  match 'page/about' => 'page#about', :via => [:get]
  match 'page/tutorial' => 'page#tutotial', :via => [:get]
  match 'page/preview/:id' => 'page#preview', :via => [:get]
  match 'page/:id' => 'page#show', :via => [:get]

  match 'transcript_lines/:id/resolve' => 'transcript_lines#resolve', :via => [:post]

  # admin
  namespace :admin do
    resources :users, only: [:index, :update]
    resources :transcripts, only: [:index]
    resources :flags, only: [:index]

    get 'cms', to: 'cms#show'
    namespace :cms do
      resources :collections, except: [:index]
      resources :transcripts, except: [:show, :index] do
        get "speaker_search", on: :collection
        get "sync", on: :member
        post "process_transcript", on: :member
        delete "reset_transcript", on: :member
      end
    end
  end
  match 'admin' => 'admin/stats#index', :via => [:get], :as => :admin

  # moderator
  namespace :moderator do
    resources :flags, only: [:index]
  end
  match 'moderator' => 'admin/flags#index', :via => [:get], :as => :moderator

  resources :home, only: [:index, :transcripts] do
    collection do
      post "transcripts"
    end
  end

  resources :dashboard, only: [:index]
  resources :search, only: [:index] do
    collection do
      get 'query'
    end
  end

  match 'authenticate' => "authentication#authenticate", :via => [:post]

  # temp routes for testing new UI
  get 'v2/home',   to: 'v2#home'
  get 'v2/edit',   to: 'v2#edit'
  get 'v2/search', to: 'v2#search'

  # root :to => 'default#index'
  root :to => 'home#index'

  match '*path' => "institutions#index", via: [:get]
end
