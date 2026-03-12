Rails.application.routes.draw do
  devise_for :users
  root "mangas#index"

  resources :mangas, only: [ :index, :show, :edit, :new, :create, :update, :destroy ]
end
