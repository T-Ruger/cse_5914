class Movie < ApplicationRecord
	has_many :viewings
	has_many :users, through: :viewings
end
