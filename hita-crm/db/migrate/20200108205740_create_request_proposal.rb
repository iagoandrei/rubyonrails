class CreateRequestProposal < ActiveRecord::Migration[6.0]
  def change
    create_table :request_proposals do |t|
      t.boolean :is_accepted, default: false
      t.timestamps
    end

    add_reference :request_proposals, :request
  end
end
