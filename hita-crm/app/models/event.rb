class Event < ApplicationRecord
  has_and_belongs_to_many :users
  belongs_to :enterprise, optional: true
  belongs_to :owner, :class_name => 'User', optional: true
  has_many :interactions, dependent: :destroy
  has_many :notifications, dependent: :destroy

  EVENT_TYPE = {
    training: 'Treinamento',
    seminar: 'Seminário',
    meeting: 'Reunião',
    visit: 'Visita',
    other: 'Outro'
  }

  STATUS = {finished: 0, active: 1}
end
