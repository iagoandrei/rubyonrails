class AddPositionToRequestQuiz < ActiveRecord::Migration[6.0]
  def change
    add_column :request_quizzes, :position, :integer, limit: 2
  end
end
