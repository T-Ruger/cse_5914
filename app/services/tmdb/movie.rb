require_relative 'base'
module Tmdb
  class Movie < Base
    attr_accessor :title,
    :year, :poster

    MAX_LIMIT = 12

    def self.find(title)
      query = {}
      response = Request.get("", query.merge({ page: 1, r: "json", s: title}))
      Movie.new(response)
    end

    def initialize(args = {})
      super(args)
      parse_json(args)
    end

    def parse_json(args = {})
      result = args['Search'][0]
      self.title = result["Title"]
      self.year = result["Year"]
      self.poster = result['Poster']
    end
  end
end
