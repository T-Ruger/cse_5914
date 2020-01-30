require 'faraday'
require 'json'

class Connection
	BASE = 'https://movie-database-imdb-alternative.p.rapidapi.com'

	def self.api
		Faraday.new(url: BASE) do |faraday|
			faraday.response :logger
			faraday.adapter Faraday.default_adapter
			faraday.headers['X-RapidAPI-Key'] = '0db73d56f8mshea5c59eb021fe13p1e1c8fjsn5c83005afd96'
    	end
  	end
end