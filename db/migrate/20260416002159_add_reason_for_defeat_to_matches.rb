class AddReasonForDefeatToMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :matches, :reason_for_defeat, :integer
  end
end
