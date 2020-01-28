#1/28 Caleb Fischer: Added rooms and room messages
Rails.application.routes.draw do
  resources :room_messages
  resources :rooms
  devise_for :users do
  	get '/users/sign_out', to: 'devise/sessions#destroy'
  end
  
  root controller: :rooms, action: :index
  resources :room_messages
  resources :rooms
  
  #root to: "static_page#home"
  get '/movies', to: "static_page#movies"
  get '/about', to: "static_page#about"
end
