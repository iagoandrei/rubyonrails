class FormKey < ApplicationRecord
  belongs_to :request_quiz, class_name: 'RequestQuiz', foreign_key: 'request_quizzes_id'

  validates :key_name,
    length: {
      :within => 2..255,
      :message => I18n.t('form.error.invalid_string_size')
    },
    presence: { message: I18n.t('form.error.empty') }

  serialize :conditions, Array
  serialize :answers_to_print, Array
end
