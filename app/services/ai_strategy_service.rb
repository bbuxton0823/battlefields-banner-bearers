class AIStrategyService
  def initialize(battle)
    @battle = battle
    @difficulty = battle.ai_difficulty || 'normal'
    @settings = DifficultyService.get_difficulty_settings(@difficulty)
  end

  def calculate_best_move(battle_unit)
    return nil unless battle_unit.army_id != @battle.player_army_id

    possible_targets = find_possible_targets(battle_unit)
    return nil if possible_targets.empty?

    # Calculate best target based on multiple factors
    best_target = nil
    best_score = -Float::INFINITY

    possible_targets.each do |target|
      score = calculate_target_score(battle_unit, target)
      if score > best_score
        best_score = score
        best_target = target
      end
    end

    {
      action: 'attack',
      unit: battle_unit,
      target: best_target,
      score: best_score
    }
  end

  def calculate_unit_priority(unit)
    base_priority = unit.unit.attack + unit.unit.defense
    
    # Health modifier - damaged units are higher priority
    health_modifier = (100 - unit.health) * 0.5
    
    # Morale modifier - low morale units are easier targets
    morale_modifier = (100 - unit.morale) * 0.3
    
    # Position modifier - units closer to objectives get higher priority
    position_modifier = calculate_position_value(unit)
    
    base_priority + health_modifier + morale_modifier + position_modifier
  end

  def should_retreat?(battle_unit)
    return false if battle_unit.morale > 30
    
    # More likely to retreat on higher difficulties
    retreat_threshold = case @difficulty.to_sym
    when :easy then 10
    when :normal then 20
    when :hard then 30
    when :expert then 40
    else 20
    end
    
    battle_unit.morale < retreat_threshold
  end

  def get_formation_advice(units)
    return [] if units.empty?

    # Simple formation advice based on unit types
    advice = []
    
    # Group units by type
    infantry = units.select { |u| u.unit.unit_type == 'infantry' }
    cavalry = units.select { |u| u.unit.unit_type == 'cavalry' }
    archers = units.select { |u| u.unit.unit_type == 'archer' }
    
    # Basic formation suggestions
    if archers.any?
      advice << "Position archers on high ground for maximum range"
    end
    
    if cavalry.any?
      advice << "Use cavalry for flanking maneuvers"
    end
    
    if infantry.any?
      advice << "Form infantry into defensive lines"
    end
    
    advice
  end

  private

  def find_possible_targets(attacker)
    @battle.battle_units
           .where.not(army_id: attacker.army_id)
           .where('health > 0')
  end

  def calculate_target_score(attacker, target)
    # Base damage calculation
    attack_power = attacker.unit.attack + @settings[:ai_attack_bonus]
    defense_power = target.unit.defense
    
    # Expected damage
    expected_damage = [attack_power - defense_power, 1].max
    
    # Target value based on unit importance
    target_value = calculate_unit_priority(target)
    
    # Distance factor (closer targets preferred)
    distance = calculate_distance(attacker, target)
    distance_factor = 1.0 / (distance + 1)
    
    # Final score
    (expected_damage * target_value * distance_factor)
  end

  def calculate_position_value(unit)
    # Simple position scoring - can be enhanced with actual battlefield positions
    50 # Neutral value for now
  end

  def calculate_distance(unit1, unit2)
    # Simple distance calculation - can be enhanced with actual battlefield coordinates
    1 # Default distance
  end
end