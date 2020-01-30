require_relative("../services/movie/movie.rb")
include Imdb
class MovieController < ApplicationController
  def show
    @result = Imdb::Movie.find(params[:search])
  end
end
