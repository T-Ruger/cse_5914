class ChangeDirectorName < ActiveRecord::Migration[5.2]
  def change
  	rename_column :rooms, :director, :people
  end
end
