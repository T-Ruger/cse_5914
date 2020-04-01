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

  get '/resetHome', to: "static_page#setNil"
  
  get '/home', to: "static_page#home"
  get '/suggestions', to: "static_page#suggestions"
  get '/movies', to: "static_page#movies"
  get '/about', to: "static_page#about"
  get '/catalog', to: "static_page#movies"
  get '/search', to: "movie#show"
  get '/preferences', to: "preferences#pref"
  get '/create', to: "movies#create"
  get '/create_watch', to: "movies#create_watch"
  get '/viewingscreate', to: "viewings#create"
end
