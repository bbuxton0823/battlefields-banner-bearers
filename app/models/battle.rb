class Battle < ApplicationRecord
  belongs_to :terrain
  has_many :battle_units, dependent: :destroy
  has_many :units, through: :battle_units

  validates :name, presence: true, length: { maximum: 200 }
  validates :status, presence: true, inclusion: { in: %w[setup active completed] }
  validates :current_turn, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :max_turns, presence: true, numericality: { greater_than: 0 }
  validates :terrain, presence: true
  validate :current_turn_cannot_exceed_max_turns

  def current_turn_cannot_exceed_max_turns
    if current_turn.present? && max_turns.present? && current_turn > max_turns
      errors.add(:current_turn, "must be less than or equal to #{max_turns}")
    end
  end

  after_initialize :set_defaults

  private

  def set_defaults
    self.status ||= 'setup'
    self.current_turn ||= 0
    self.max_turns ||= 20
  end
end
