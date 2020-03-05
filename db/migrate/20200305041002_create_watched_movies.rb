class CreateWatchedMovies < ActiveRecord::Migration[5.2]
  def change
    create_table :watched_movies do |t|
      t.string :user_id
      t.string :movie_id

      t.timestamps
    end
  end
end
