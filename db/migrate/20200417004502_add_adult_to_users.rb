class AddAdultToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :adult, :boolean
  end
end
