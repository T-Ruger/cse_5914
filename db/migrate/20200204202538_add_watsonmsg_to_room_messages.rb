class AddWatsonmsgToRoomMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :room_messages, :watsonmsg, :boolean
  end
end
