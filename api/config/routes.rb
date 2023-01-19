Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get 'csv', to: 'csv#index'
  get 'csv/new', to: 'csv#new'
end
