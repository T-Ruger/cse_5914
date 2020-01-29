class AddServiceurlToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :serviceurl, :string
  end
end
