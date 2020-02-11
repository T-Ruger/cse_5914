class AddGenreToRoomMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :room_messages, :genre, :string
  end
end
