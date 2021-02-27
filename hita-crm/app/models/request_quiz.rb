class RequestQuiz < ApplicationRecord
  belongs_to :user
  has_many :form_key, class_name: 'FormKey', foreign_key: 'request_quizzes_id', dependent: :destroy

  serialize :quiz, JSON

  before_destroy :remove_question_from_equipment
  before_create :set_position

  def get_quiz_ids
    ids = []
    parsed_data = JSON.parse(self.data)

    parsed_data["questions"].each do |question|
      current_question = {}
      current_question[:question] = { id: question['id'], text: question['text'] }
      current_question[:answers] = question['answers'].map { |a| { id: a['id'], text: a['text']} }
      ids << current_question
    end

    return ids
  end

  private

  def remove_question_from_equipment
    equipments = Equipment.all
    equipments.each do |equipment|
      equipment.questions.delete(self.id)
    end
  end

  def set_position
    last_quiz = RequestQuiz.all.order(position: 'ASC').first
    if last_quiz
      self.position = last_quiz.position + 1
    else
      self.position = 0
    end
  end
end
