class DropWatsonMessage < ActiveRecord::Migration[5.2]
  def change
  	drop_table :watson_messages
  end
end
