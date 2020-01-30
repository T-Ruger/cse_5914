Rails.application.routes.draw do
  devise_for :users do
  	get '/users/sign_out', to: 'devise/sessions#destroy'
  end
  root to: "static_page#home"
  get '/movies', to: "static_page#movies"
  get '/about', to: "static_page#about"
  get '/catalog', to: "static_page#movies"
  get '/facebook.com', to: "static_page#facebook"
  get '/search', to: "movie#show"
end
