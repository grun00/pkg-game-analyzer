class AddFirstOrSecondToMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :matches, :first_or_second, :integer, null: false, default: 0
  end
end
