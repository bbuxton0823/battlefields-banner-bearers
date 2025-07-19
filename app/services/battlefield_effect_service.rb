class BattlefieldEffectService
  # Terrain-based effects
  TERRAIN_EFFECTS = {
    forest: {
      name: "Forest Cover",
      description: "Provides defensive bonus to infantry and archers",
      effects: {
        infantry: { defense: 15, attack: -5 },
        archer: { defense: 10, attack: 5 },
        cavalry: { attack: -10, movement: -2 }
      }
    },
    hill: {
      name: "High Ground",
      description: "Provides attack bonus and visibility advantage",
      effects: {
        infantry: { attack: 10, defense: 5 },
        archer: { attack: 15, range: 2 },
        cavalry: { attack: 5 }
      }
    },
    river: {
      name: "River Crossing",
      description: "Movement penalty and vulnerability while crossing",
      effects: {
        infantry: { movement: -3, defense: -10 },
        cavalry: { movement: -5, attack: -15 },
        archer: { movement: -2 }
      }
    },
    plain: {
      name: "Open Plains",
      description: "Ideal for cavalry charges and maneuvering",
      effects: {
        cavalry: { attack: 10, movement: 2 },
        infantry: { movement: 1 },
        archer: { movement: 1 }
      }
    },
    mountain: {
      name: "Mountainous Terrain",
      description: "Difficult terrain with defensive advantages",
      effects: {
        infantry: { defense: 20, attack: 5, movement: -3 },
        archer: { defense: 15, attack: 10, movement: -2 },
        cavalry: { attack: -20, movement: -5 }
      }
    },
    swamp: {
      name: "Swampy Ground",
      description: "Difficult terrain that slows movement",
      effects: {
        infantry: { movement: -4, defense: -5 },
        cavalry: { movement: -6, attack: -10 },
        archer: { movement: -3 }
      }
    }
  }.freeze

  def initialize(battle_unit, terrain)
    @battle_unit = battle_unit
    @unit = battle_unit.unit
    @terrain = terrain
  end

  # Apply terrain effects to the battle unit
  def apply_terrain_effects
    return unless TERRAIN_EFFECTS.key?(@terrain.name.to_sym)

    effects = TERRAIN_EFFECTS[@terrain.name.to_sym][:effects]
    unit_type = @unit.unit_type.downcase.to_sym

    return unless effects.key?(unit_type)

    unit_effects = effects[unit_type]
    
    # Apply temporary bonuses
    unit_effects.each do |stat, modifier|
      case stat
      when :attack
        @battle_unit.temp_attack_bonus += modifier
      when :defense
        @battle_unit.temp_defense_bonus += modifier
      when :movement
        @battle_unit.temp_movement_bonus += modifier
      end
    end

    @battle_unit.save!
    
    {
      terrain: @terrain.name,
      effects: unit_effects
    }
  end

  # Calculate combat modifier based on terrain
  def combat_modifier
    return 0 unless TERRAIN_EFFECTS.key?(@terrain.name.to_sym)

    effects = TERRAIN_EFFECTS[@terrain.name.to_sym][:effects]
    unit_type = @unit.unit_type.downcase.to_sym

    return 0 unless effects.key?(unit_type)

    unit_effects = effects[unit_type]
    
    # Calculate overall combat effectiveness
    attack_modifier = unit_effects[:attack] || 0
    defense_modifier = unit_effects[:defense] || 0
    
    attack_modifier + defense_modifier
  end

  # Check if terrain provides defensive bonus
  def defensive_bonus
    return 0 unless TERRAIN_EFFECTS.key?(@terrain.name.to_sym)

    effects = TERRAIN_EFFECTS[@terrain.name.to_sym][:effects]
    unit_type = @unit.unit_type.downcase.to_sym

    return 0 unless effects.key?(unit_type)

    effects[unit_type][:defense] || 0
  end

  # Check if terrain provides attack bonus
  def attack_bonus
    return 0 unless TERRAIN_EFFECTS.key?(@terrain.name.to_sym)

    effects = TERRAIN_EFFECTS[@terrain.name.to_sym][:effects]
    unit_type = @unit.unit_type.downcase.to_sym

    return 0 unless effects.key?(unit_type)

    effects[unit_type][:attack] || 0
  end

  # Get movement penalty/bonus for terrain
  def movement_modifier
    return 0 unless TERRAIN_EFFECTS.key?(@terrain.name.to_sym)

    effects = TERRAIN_EFFECTS[@terrain.name.to_sym][:effects]
    unit_type = @unit.unit_type.downcase.to_sym

    return 0 unless effects.key?(unit_type)

    effects[unit_type][:movement] || 0
  end

  # Get terrain description for UI
  def terrain_description
    return "No special terrain effects" unless TERRAIN_EFFECTS.key?(@terrain.name.to_sym)

    TERRAIN_EFFECTS[@terrain.name.to_sym][:description]
  end

  # Get all terrain effects for display
  def terrain_effects_summary
    return {} unless TERRAIN_EFFECTS.key?(@terrain.name.to_sym)

    effects = TERRAIN_EFFECTS[@terrain.name.to_sym][:effects]
    unit_type = @unit.unit_type.downcase.to_sym

    return {} unless effects.key?(unit_type)

    {
      terrain: @terrain.name,
      effects: effects[unit_type],
      description: TERRAIN_EFFECTS[@terrain.name.to_sym][:description]
    }
  end

  # Check if unit is at disadvantage in this terrain
  def terrain_disadvantage?
    combat_modifier < 0
  end

  # Check if unit has advantage in this terrain
  def terrain_advantage?
    combat_modifier > 0
  end

  # Get neighboring positions for flanking calculations
  def get_flanking_positions(position_x, position_y)
    [
      [position_x - 1, position_y - 1], [position_x, position_y - 1], [position_x + 1, position_y - 1],
      [position_x - 1, position_y],                                   [position_x + 1, position_y],
      [position_x - 1, position_y + 1], [position_x, position_y + 1], [position_x + 1, position_y + 1]
    ].select { |x, y| x >= 0 && y >= 0 && x < 10 && y < 10 }
  end

  # Check if position provides flanking bonus
  def flanking_bonus?(attacker_pos, defender_pos)
    # Simple flanking: attacker is not directly in front
    dx = (attacker_pos[0] - defender_pos[0]).abs
    dy = (attacker_pos[1] - defender_pos[1]).abs
    
    # Not directly in front (same column or row)
    dx > 0 && dy > 0
  end

  # Calculate line of sight for ranged units
  def line_of_sight?(from_pos, to_pos, blocking_units = [])
    # Simple line of sight: check if any units are between positions
    x1, y1 = from_pos
    x2, y2 = to_pos
    
    # Calculate the line between positions
    dx = x2 - x1
    dy = y2 - y1
    
    # Check intermediate positions
    steps = [dx.abs, dy.abs].max
    return true if steps <= 1
    
    (1..steps - 1).each do |step|
      t = step.to_f / steps
      check_x = (x1 + dx * t).round
      check_y = (y1 + dy * t).round
      
      # Check if any unit is at this position
      blocking_units.each do |unit|
        if unit.position_x == check_x && unit.position_y == check_y
          return false
        end
      end
    end
    
    true
  end
end