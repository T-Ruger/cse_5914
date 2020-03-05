json.extract! movie, :id, :movie_id, :poster_url, :title, :short_desc, :created_at, :updated_at
json.url movie_url(movie, format: :json)
