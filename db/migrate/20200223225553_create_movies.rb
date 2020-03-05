class CreateMovies < ActiveRecord::Migration[5.2]
  def change
    create_table :movies, id: false do |t|
      t.integer :movie_id, primary_key: true
      t.string :poster_url
      t.string :title
      t.string :short_desc

      t.timestamps
    end
  end
end
