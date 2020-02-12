class ChangeColumnName < ActiveRecord::Migration[5.2]
  def change
  	rename_column :room_messages, :attributes, :params
  end
end
