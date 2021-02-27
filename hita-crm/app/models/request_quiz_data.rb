class RequestQuizData < ApplicationRecord
  belongs_to :request

  serialize :data, JSON

  def get_user_answers_ids
    ids = []
    parsed_data = JSON.parse(self.data)

    parsed_data["questions"].each do |question|
      ids += question['user_answers'].map { |a| a['id'].to_s }
    end

    return ids
  end
end
