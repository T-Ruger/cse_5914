class AddMovieIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :movie_id, :integer
  end
end
