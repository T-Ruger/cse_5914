class AddColumnsToRoom < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :genre, :string
    add_column :rooms, :director, :string
    add_column :rooms, :timeperiod, :string
    add_column :rooms, :length, :string
  end
end
