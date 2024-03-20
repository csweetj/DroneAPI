Rails.application.routes.draw do
  resources :flights, only: [:create, :index]
end
