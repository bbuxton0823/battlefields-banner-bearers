class Terrain < ApplicationRecord
  has_many :battles, dependent: :destroy
  has_many :battlefield_effects, dependent: :destroy
  has_many :armies, through: :battlefield_effects

  validates :name, presence: true, length: { maximum: 100 }
  validates :terrain_type, presence: true, inclusion: { in: %w[Desert Mountain Forest Plains Arctic] }, length: { maximum: 50 }
  validates :climate, presence: true, length: { maximum: 50 }
  validates :mobility_modifier, numericality: { greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }
  validates :heat_stress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :cold_stress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :disease_risk, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :visibility, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :description, presence: true
  validates :historical_significance, presence: true
end
