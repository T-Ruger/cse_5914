class FixUserMovie < ActiveRecord::Migration[5.2]
  def self.up
  	rename_column :viewings, :movies, :movie_id
  	rename_column :viewings, :users, :user_id
  end
end
