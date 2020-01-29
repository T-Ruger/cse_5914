class AddSessionidToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :sessionid, :string
  end
end
