class CreateSongs < ActiveRecord::Migration
  
  def change
    create_table :songs do |t|
      t.string :title, :author, :url
      t.integer :user_id
      t.timestamps null: false
    end
  end
end

