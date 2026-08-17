class AddGameModeToMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :matches, :game_mode, :integer, null: false, default: 0
  end
end
