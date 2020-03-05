class CreateViewings < ActiveRecord::Migration[5.2]
  def change
    create_table :viewings do |t|
      t.string :movies
      t.string :users

      t.timestamps
    end
  end
end
