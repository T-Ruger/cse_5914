class AddCreatorToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :creator, :string
  end
end
