class CreateWatsonMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :watson_messages do |t|

      t.timestamps
    end
  end
end
