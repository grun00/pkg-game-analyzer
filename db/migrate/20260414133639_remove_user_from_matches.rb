class RemoveUserFromMatches < ActiveRecord::Migration[7.2]
  def change
    remove_reference :matches, :user, null: false, foreign_key: true
  end
end
