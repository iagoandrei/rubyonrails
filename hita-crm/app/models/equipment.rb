class Equipment < ApplicationRecord
  self.table_name = 'equipments'
  has_one_attached :image_1, dependent: :destroy
  has_one_attached :image_2, dependent: :destroy
  has_one_attached :image_3, dependent: :destroy
  has_many :request

  serialize :questions, Array

  def add_question question_id
    self.questions << question_id unless question_id.in? self.questions
    self.save
  end

  def remove_question question_id
    self.questions -= [question_id]
    self.save
  end

  def images_links
    images = []
    images << Rails.application.routes.url_helpers.rails_blob_path(self.image_1) if self.image_1.attached?
    images << Rails.application.routes.url_helpers.rails_blob_path(self.image_2) if self.image_2.attached?
    images << Rails.application.routes.url_helpers.rails_blob_path(self.image_3) if self.image_3.attached?
    return images
  end

  def get_request_quiz
    request_quiz = RequestQuiz.where(id: self.questions).order(position: 'ASC').pluck(:data)
    return request_quiz
  end
end
