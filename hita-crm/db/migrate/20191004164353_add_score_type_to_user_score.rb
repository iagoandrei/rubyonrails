class AddScoreTypeToUserScore < ActiveRecord::Migration[6.0]
  def change
    add_column :user_scores, :score_type, :string
  end
end
