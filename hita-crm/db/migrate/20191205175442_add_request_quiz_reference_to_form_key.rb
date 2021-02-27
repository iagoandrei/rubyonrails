class AddRequestQuizReferenceToFormKey < ActiveRecord::Migration[6.0]
  def change
  	add_reference :form_keys, :request_quizzes
  end
end
