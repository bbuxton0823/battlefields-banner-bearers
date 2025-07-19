class BattleUnit < ApplicationRecord
  belongs_to :battle
  belongs_to :unit
  belongs_to :army
  
  validates :health, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :morale, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :position_x, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :position_y, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # --------------------------------------------------------------------------
  # Temporary bonuses
  # --------------------------------------------------------------------------
  # These attributes are now backed by real database columns (see the
  # `AddTempBonusesToBattleUnits` migration).  We keep the after_initialize
  # guard below to ensure any records created before the migration (or loaded
  # without the new columns) still receive sane default values.

  # --------------------------------------------------------------------------
  # Callbacks
  # --------------------------------------------------------------------------

  # Ensure bonuses are always numeric to avoid nil checks sprinkled
  # throughout the combat code.
  after_initialize :initialize_temp_bonuses
  
  # Effective stats including temporary bonuses
  def effective_attack
    [unit.attack + (temp_attack_bonus || 0), 0].max
  end
  
  def effective_defense
    [unit.defense + (temp_defense_bonus || 0), 0].max
  end
  
  def effective_morale
    # Keep morale within 0-100 range
    [[morale + (temp_morale_bonus || 0), 0].max, 100].min
  end
  
  def effective_movement
    [unit.movement + (temp_movement_bonus || 0), 0].max
  end
  
  # Special ability management
  def can_use_ability?
    return false unless unit.special_ability.present?
    return false if health <= 0
    
    # Check cooldown
    return false if last_ability_use && last_ability_use > 1.minute.ago
    
    true
  end
  
  # Check if unit is active
  def active?
    health > 0
  end
  
  # Unit type helpers
  def unit_type
    unit.unit_type
  end
  
  def special_ability
    unit.special_ability
  end
  
  def name
    unit.name
  end
  
  def attack
    unit.attack
  end
  
  def defense
    unit.defense
  end
  
  def movement
    unit.movement
  end

  private

  # Sets default values for temporary bonuses so they never return nil
  def initialize_temp_bonuses
    self.temp_attack_bonus   ||= 0
    self.temp_defense_bonus  ||= 0
    self.temp_morale_bonus   ||= 0
    self.temp_movement_bonus ||= 0
  end
end