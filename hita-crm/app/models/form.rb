class Form < ApplicationRecord
  has_one_attached :template, dependent: :destroy
end
