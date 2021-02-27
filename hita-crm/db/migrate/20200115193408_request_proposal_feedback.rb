class RequestProposalFeedback < ActiveRecord::Migration[6.0]
  def change
  	remove_column :request_proposals, :is_accepted, :boolean
  	add_column :request_proposals, :status, :string, default: 'not_evaluated'
  	add_column :request_proposals, :feedback_description, :text
  	add_column :request_proposals, :feedback_reasons, :text
  end
end
