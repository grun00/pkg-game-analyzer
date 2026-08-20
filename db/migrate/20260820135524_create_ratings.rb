class CreateRatings < ActiveRecord::Migration[7.2]
  def change
    create_table :ratings do |t|
      t.references :content, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :stars, null: false

      t.timestamps
    end

    add_index :ratings, %i[user_id content_id], unique: true
  end
end
