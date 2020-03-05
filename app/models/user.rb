class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, uniqueness: true, presence: true

  has_many :room_messages,
           dependent: :destroy
  has_many :viewings
  has_many :watched_movies
  has_many :seen_movies, :class_name => 'Movie', :through => :viewings, :source => :movie
  has_many :watch_movies, :class_name => 'Movie', :through => :watched_movies, :source => :movie
  def gravatar_url
    gravatar_id = Digest::MD5::hexdigest(email).downcase
    "https://gravatar.com/avatar/#{gravatar_id}.png"
  end
end
