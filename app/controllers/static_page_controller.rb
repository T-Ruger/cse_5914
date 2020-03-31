require 'net/http'
require 'json'
class StaticPageController < ApplicationController
	def home
		puts current_user.movie_id
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
	end
end
