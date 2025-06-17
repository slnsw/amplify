# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  post '/csp-violation-report-endpoint', to: 'api/csp_reports#create'

  namespace :api do
    namespace :institutions do
      resources :guids, only: [:index]
    end
  end

  namespace :admin do
    resources :profiles, only: %i[index update]

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
    resources :app_configs, only: %i[edit update]
    resources :stats, only: [:index] do
      member do
        get :institution
      end
    end
    resources :reports, only: [:index] do
      collection do
        get :edits
        get :transcripts
        get :users
      end
    end
    resources :summary, only: [:index] do
      collection do
        get :details
      end
    end
    resources :analytics, only: [:index] do
    end
  end
  resources :flags, only: %i[index show create update destroy]
  resources :transcript_speaker_edits, only: %i[index show create update destroy]
  resources :transcript_edits, only: %i[index show create]
  resources :transcript_files, only: %i[index show]
  resources :transcripts, only: %i[index show]
  get 'transcripts/:institution/:collection/:id', to: 'transcripts#show', as: 'institution_transcript'

  resources :collections, only: %i[index show] do
    collection do
      post :list
    end
  end

  devise_for(
    :users,
    controllers: {
      sessions: 'users/sessions',
      omniauth_callbacks: 'users/omniauth_callbacks',
      registrations: 'users/registrations',
      passwords: 'users/passwords'
    }
  )

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get 'page/faq' => 'page#faq'
  get 'page/about' => 'page#about'
  get 'page/tutorial' => 'page#tutotial'
  get 'page/preview/:id' => 'page#preview'
  get 'page/:id' => 'page#show'

  post 'transcript_lines/:id/resolve' => 'transcript_lines#resolve'

  # admin
  namespace :admin do
    resources :users, only: %i[index update destroy]
    resources :transcripts, only: [:index]
    resources :flags, only: [:index]
    resources :site_alerts

    get 'cms', to: 'cms#show'
    namespace :cms do
      resources :collections, except: [:index]
      resources :transcripts, except: %i[show index] do
        put :update_multiple, on: :collection
        get 'speaker_search', on: :collection
        get 'sync', on: :member
        post 'process_transcript', on: :member
        delete 'reset_transcript', on: :member
      end
    end
  end
  get 'admin' => 'admin/stats#index', :as => :admin

  # moderator
  namespace :moderator do
    resources :flags, only: [:index]
  end
  get 'moderator' => 'admin/flags#index', :as => :moderator

  resources :home, only: [:index]
  resources :search, only: [:index]
  resources :dashboard, only: [:index]

  post 'authenticate' => 'authentication#authenticate'

  # temp routes for testing new UI
  get 'v2/home',   to: 'v2#home'
  get 'v2/edit',   to: 'v2#edit'
  get 'v2/search', to: 'v2#search'

  root to: 'home#index'

  get '*path' => 'institutions#index', as: :institution
end
