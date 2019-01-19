Rails.application.routes.draw do
  resources :products
  post 'login', to: 'authentication#authenticate'
end
