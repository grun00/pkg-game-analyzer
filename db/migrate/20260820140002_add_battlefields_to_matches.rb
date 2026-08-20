class AddBattlefieldsToMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :matches, :my_battlefield, :string
    add_column :matches, :opponent_battlefield, :string
  end
end
