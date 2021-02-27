class AddRequestProposalToUserScore < ActiveRecord::Migration[6.0]
  def change
    add_reference :user_scores, :request_proposal
  end
end
