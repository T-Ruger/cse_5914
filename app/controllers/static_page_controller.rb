require 'net/http'
require 'json'
class StaticPageController < ApplicationController
	def home
		if current_user.movie_id != nil
			redirect_to "/suggestions" 
		end
	end
	def suggestions
		url = 'https://api.themoviedb.org/3/movie/'+ current_user.movie_id.to_s + '/similar?api_key=305ae312343163e9a891637b00d624c9&language=en-US&page=1'
		uri = URI(url)
		response = Net::HTTP.get(uri)
		jsonStr = JSON.parse(response)
		@results =  jsonStr['results']
		@last_movie = Movie.find current_user.movie_id
		puts @last_movie
	end
	def setNil
		current_user.movie_id = nil
		current_user.save
		redirect_to "/home"
	end
	def updateRatings
		url = 'https://api.themoviedb.org/3/movie/'+ params["id"].to_s + '?api_key=305ae312343163e9a891637b00d624c9&language=en-US'
		uri = URI(url)
		response = Net::HTTP.get(uri)
		jsonStr = JSON.parse(response)
		id = params["id"].to_i
	    movies = Movie.where(movie_id: id)
	    if movies.empty?
	      movie = Movie.new
	      movie.movie_id = id
	      movie.title = jsonStr['original_title']
	      movie.poster_url = jsonStr['poster_path']
	      movie.short_desc = jsonStr['overview']
	      puts movie
	      if movie.save
	        puts "yes"
	      end
	    else
	      movie = movies.first
	    end
	    if (!current_user.seen_movies.include?(movie))
	      current_user.seen_movies << movie
	    end
	    viewings = Viewing.where(user_id: current_user.id, movie_id: id)
	    viewings.first.rating = params["rating"]
	    viewings.first.save
	end
end
