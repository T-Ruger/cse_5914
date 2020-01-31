require 'faraday'
require 'json'

class Connection
	BASE = 'https://movie-database-imdb-alternative.p.rapidapi.com'

	def self.api
		Faraday.new(url: BASE) do |faraday|
			faraday.response :logger
			faraday.adapter Faraday.default_adapter
			faraday.headers['api_key'] = '305ae312343163e9a891637b00d624c9'
    	end
  	end
end