class AddLastintentToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :lastIntent, :string
  end
end
