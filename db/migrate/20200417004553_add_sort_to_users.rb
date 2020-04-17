class AddSortToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sort, :string
  end
end
