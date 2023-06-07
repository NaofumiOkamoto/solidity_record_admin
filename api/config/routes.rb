Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get 'csv', to: 'csv#index'
  get 'csv/new', to: 'csv#new'
  get 'delete_product_csv/new', to: 'delete_product_csv#new'
end
