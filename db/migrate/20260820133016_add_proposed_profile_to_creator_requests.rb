class AddProposedProfileToCreatorRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :creator_requests, :proposed_name, :string
    add_column :creator_requests, :proposed_bio, :text
  end
end
