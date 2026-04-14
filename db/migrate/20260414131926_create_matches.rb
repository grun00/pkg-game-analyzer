class CreateMatches < ActiveRecord::Migration[7.2]
  def change
    create_table :matches do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :opponent_deck, null: false
      t.string :result, null: false
      t.text :description
      t.integer :hand_quality, null: false
      t.datetime :played_at, null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end
  end
end
