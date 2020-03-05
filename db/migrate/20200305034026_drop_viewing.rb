class DropViewing < ActiveRecord::Migration[5.2]
  def change
  	drop_table :viewings
  end
end
