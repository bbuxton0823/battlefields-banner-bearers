class Unit < ApplicationRecord
  belongs_to :army
  has_many :battle_units, dependent: :destroy
  has_many :battles, through: :battle_units

  validates :name, presence: true, length: { maximum: 100 }
  validates :unit_type, presence: true, inclusion: { in: %w[infantry cavalry archer artillery support] }, length: { maximum: 50 }
  validates :attack, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :defense, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :health, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :morale, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :movement, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :description, presence: true
  validates :army, presence: true
end
