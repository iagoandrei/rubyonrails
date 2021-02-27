class AddIsPrintableAndAnswersToPrintToFormKeys < ActiveRecord::Migration[6.0]
  def change
    add_column :form_keys, :is_answer_printable, :boolean, default: false
    add_column :form_keys, :answers_to_print, :text
  end
end
