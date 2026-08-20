class AddGameTypeToDashboards < ActiveRecord::Migration[7.2]
  def change
    add_column :dashboards, :game_type, :integer, null: false, default: 0
    add_index :dashboards, :game_type
  end
end
