class AddRequestToUserScore < ActiveRecord::Migration[6.0]
  def change
    add_reference :user_scores, :request, index: true
  end
end
