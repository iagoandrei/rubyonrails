class CreateRequestQuiz < ActiveRecord::Migration[6.0]
  def change
    create_table :request_quizzes do |t|
      t.string :title
      t.text :data
      t.references :user
      t.timestamps
    end
  end
end
