class CreateRequestQuizData < ActiveRecord::Migration[6.0]
  def change
    create_table :request_quiz_data do |t|
      t.text :data
    end

    add_reference :request_quiz_data, :request
  end
end
