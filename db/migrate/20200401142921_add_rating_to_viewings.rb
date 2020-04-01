class AddRatingToViewings < ActiveRecord::Migration[5.2]
  def change
    add_column :viewings, :rating, :string
  end
end
