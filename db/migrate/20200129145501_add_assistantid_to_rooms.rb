class AddAssistantidToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :assistantid, :string
  end
end
