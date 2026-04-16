class AddNumberOfMulligansToMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :matches, :number_of_mulligans, :integer
  end
end
