class AddAttributesToRoomMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :room_messages, :attributes, :string
  end
end
