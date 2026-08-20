class AddGameTypeToContents < ActiveRecord::Migration[7.2]
  def change
    add_column :contents, :game_type, :integer, null: false, default: 0
  end
end
