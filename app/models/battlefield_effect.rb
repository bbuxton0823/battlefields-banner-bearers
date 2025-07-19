class BattlefieldEffect < ApplicationRecord
  belongs_to :terrain
  belongs_to :army

  validates :terrain, presence: true
  validates :army, presence: true
  validates :mobility_penalty, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :heat_penalty, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :cold_penalty, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :disease_risk, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :visibility_penalty, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :morale_modifier, numericality: true, allow_nil: true
  validates :description, presence: true, length: { maximum: 500 }
  validates :terrain_id, uniqueness: { scope: :army_id }
end
