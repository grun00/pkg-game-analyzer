class CreateCreatorRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :creator_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.text :message

      t.timestamps
    end

    add_index :creator_requests, :status
  end
end
