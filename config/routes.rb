Rails.application.routes.draw do
  resources :viewings
  resources :movies
 # devise_for :users

  #root controller: :rooms, action: :index

  resources :room_messages
  resources :rooms
  
  devise_for :users do
  	get '/users/sign_out', to: 'devise/sessions#destroy'
  end
  
  root to: "static_page#home"
  
  get '/home', to: "static_page#home"
  get '/movies', to: "static_page#movies"
  get '/about', to: "static_page#about"
  get '/catalog', to: "static_page#movies"
  get '/search', to: "movie#show"
end
