class AddApikeyToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :apikey, :string
  end
end
