class AddDashboardToMatches < ActiveRecord::Migration[7.2]
  def change
    add_reference :matches, :dashboard, null: false, foreign_key: true
  end
end
