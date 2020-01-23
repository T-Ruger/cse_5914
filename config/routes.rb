Rails.application.routes.draw do
  devise_for :users

  root to: "static_page#home"
  get '/movies', to: "static_page#movies"
end
