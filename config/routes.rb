Rails.application.routes.draw do
  root "mangas#index"

  devise_for :users

  resources :mangas do
    member do
      post   :bookmark
      delete :bookmark
    end
    resources :chapters,
          only: [ :show, :new, :create, :edit, :update, :destroy ],
          constraints: { id: /[0-9]+(\.[0-9]+)?/ } do
      resources :pages,
            only: [ :show, :new, :create, :destroy ],
            constraints: { chapter_id: /[0-9]+(\.[0-9]+)?/ }
    end
  end

  resources :ratings, only: [ :create, :update, :destroy ]

  resources :tags, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

  get "library", to: "library#show", as: :library

  get "admin", to: "admin#index", as: :admin_dashboard

  resources :donations, only: [ :new, :create ] do
    collection do
      get :success
      get :cancel
    end
  end

  post "webhooks/stripe", to: "webhooks/stripe#create"
end
