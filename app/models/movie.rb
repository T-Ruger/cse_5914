class Movie < ApplicationRecord
	has_many :viewings
	has_many :watched_movies
	has_many :seen_users, :class_name => 'User', :through => :viewings
	has_many :watch_users, :class_name => 'User', :through => :watched_movies
end
