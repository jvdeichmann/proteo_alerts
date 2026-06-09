class Person < ApplicationRecord
  has_many :monitoring_alerts, dependent: :destroy

  validates :name, presence: true
  validates :document, presence: true, uniqueness: true
end
