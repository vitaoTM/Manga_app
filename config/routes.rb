Rails.application.routes.draw do
  root "mangas#index"

  devise_for :users

  devise_scope :user do
    delete "users/avatar", to: "users/avatars#destroy", as: :remove_avatar
  end

  resources :mangas do
    resources :chapters, only: [ :show, :create, :new, :edit, :update ] do
      resources :pages, only: [ :show, :new, :create ]
    end
  end

  namespace :user do
    resource :library, only: [ :show ]
    resource :history, only: [ :show ]
  end

  get "admin", to: "admin#index", as: :admin_dashboard
  # namespace :admin do
  #   root "dashboard#admin"
  #   resources :mangas do
  #     resources :chapters
  #   end
  #   resources :tags
  # end
end
