class RoomAttributesToParams < ActiveRecord::Migration[5.2]
  def change
  	remove_column :rooms, :people
  	remove_column :rooms, :genre
  	remove_column :rooms, :timeperiod
  	remove_column :rooms, :length
  	add_column :rooms, :params, :string
  end
end
