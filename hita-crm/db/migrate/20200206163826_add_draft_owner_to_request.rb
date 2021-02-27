class AddDraftOwnerToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :draft_owner_id, :bigint
  end
end
