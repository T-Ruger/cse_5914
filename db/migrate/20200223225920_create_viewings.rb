class CreateViewings < ActiveRecord::Migration[5.2]
  def change
    create_table :viewings do |t|
      t.integer :rating
      t.references :user, foreign_key: true
      t.references :movie, foreign_key: true
      t.timestamps
    end
  end
end
