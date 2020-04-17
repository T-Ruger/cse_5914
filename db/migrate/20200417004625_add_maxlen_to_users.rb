class AddMaxlenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :max_len, :integer
  end
end
