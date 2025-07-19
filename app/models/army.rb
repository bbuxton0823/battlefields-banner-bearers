class Army < ApplicationRecord
  has_many :units, dependent: :destroy
  has_many :battle_units, dependent: :destroy
  has_many :battles, through: :battle_units
  has_many :battlefield_effects, dependent: :destroy
  has_many :terrains, through: :battlefield_effects

  validates :name, presence: true, length: { maximum: 100 }
  validates :era, presence: true, length: { maximum: 50 }
  validates :core_stat, presence: true
  validates :factual_basis, presence: true
  validates :description, presence: true
  validates :historical_commander, length: { maximum: 100 }, allow_blank: true
end
