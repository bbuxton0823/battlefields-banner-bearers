class BattleReplay < ApplicationRecord
  belongs_to :battle
  belongs_to :unit, class_name: 'BattleUnit', optional: true
  belongs_to :target, class_name: 'BattleUnit', optional: true

  validates :action_type, presence: true
  validates :turn_number, presence: true, numericality: { greater_than: 0 }

  scope :for_battle, ->(battle) { where(battle: battle) }
  scope :chronological, -> { order(:created_at) }
  scope :by_turn, ->(turn) { where(turn_number: turn) }

  ACTION_TYPES = %w[
    move
    attack
    defend
    special_ability
    morale_check
    retreat
    reinforce
    victory
    defeat
  ].freeze

  validates :action_type, inclusion: { in: ACTION_TYPES }

  def self.record_action(battle, action_type, unit, target = nil, details = {})
    create!(
      battle: battle,
      turn_number: battle.current_turn,
      action_type: action_type,
      unit: unit,
      target: target,
      details: details,
      timestamp: Time.current
    )
  end
end