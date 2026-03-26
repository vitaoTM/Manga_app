Rails.application.routes.draw do
  root "mangas#index"

  devise_for :users

  resources :mangas do
    member do
      post   :bookmark
      delete :bookmark, action: :unbookmark
    end
    resources :chapters, only: [ :show, :create, :new, :edit, :update ] do
      resources :pages, only: [ :show, :new, :create, :destroy ]
    end
  end

  get "library", to: "library#show", as: :library

  get "admin", to: "admin#index", as: :admin_dashboard
end
