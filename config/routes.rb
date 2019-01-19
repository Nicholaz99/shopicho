Rails.application.routes.draw do
  resources :products
  resources :carts do
    resources :cart_items
  end
  post 'login', to: 'authentication#authenticate'
end
