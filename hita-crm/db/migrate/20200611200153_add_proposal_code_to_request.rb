class AddProposalCodeToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :proposal_code, :string
  end
end
