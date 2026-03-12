Rails.application.routes.draw do
  root "mangas#index"

  devise_for :users
    delete "users/avatar", to: "users/avatars#destroy", as: :remove_avatar
  resources :mangas, only: [ :index, :show, :edit, :new, :create, :update, :destroy ]
end
