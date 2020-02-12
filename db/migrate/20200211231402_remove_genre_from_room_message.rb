class RemoveGenreFromRoomMessage < ActiveRecord::Migration[5.2]
  def change
    remove_column :room_messages, :genre, :string
  end
end
