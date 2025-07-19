class SpecialAbilityService
  # Available special abilities and their effects
  ABILITIES = {
    charge: {
      name: "Cavalry Charge",
      description: "Devastating charge attack that deals double damage",
      cooldown: 3,
      effect: :charge_attack,
      valid_types: ["Cavalry"]
    },
    volley: {
      name: "Arrow Volley",
      description: "Ranged attack that can hit multiple enemies",
      cooldown: 2,
      effect: :volley_attack,
      valid_types: ["Archer"]
    },
    shield_wall: {
      name: "Shield Wall",
      description: "Defensive formation that increases defense",
      cooldown: 2,
      effect: :shield_wall_defense,
      valid_types: ["Infantry"]
    },
    bombardment: {
      name: "Artillery Bombardment",
      description: "Long-range attack that reduces enemy morale",
      cooldown: 4,
      effect: :bombardment_attack,
      valid_types: ["Artillery"]
    },
    rally: {
      name: "Rally Troops",
      description: "Boosts morale of nearby friendly units",
      cooldown: 3,
      effect: :rally_morale,
      valid_types: ["Support", "Infantry"]
    },
    flanking: {
      name: "Flanking Maneuver",
      description: "Increases attack when attacking from the side",
      cooldown: 2,
      effect: :flanking_bonus,
      valid_types: ["Cavalry"]
    }
  }.freeze

  def initialize(battle_unit)
    @battle_unit = battle_unit
    @unit = battle_unit.unit
    @battle = battle_unit.battle
  end

  # Check if unit can use a specific ability
  def can_use_ability?(ability_key)
    ability = ABILITIES[ability_key]
    return false unless ability

    # Check unit type
    return false unless ability[:valid_types].include?(@unit.unit_type)

    # Check cooldown
    return false if on_cooldown?(ability_key)

    true
  end

  # Use a special ability
  def use_ability(ability_key, target_units = [])
    return false unless can_use_ability?(ability_key)

    ability = ABILITIES[ability_key]
    effect_method = ability[:effect]

    # Apply the ability effect
    send(effect_method, target_units)

    # Set cooldown
    @battle_unit.last_ability_use = Time.current
    @battle_unit.save!

    true
  end

  # Get available abilities for this unit
  def available_abilities
    ABILITIES.select do |key, ability|
      ability[:valid_types].include?(@unit.unit_type)
    end
  end

  # Check if ability is on cooldown
  def on_cooldown?(ability_key)
    return false unless @battle_unit.last_ability_use

    ability = ABILITIES[ability_key]
    cooldown_period = ability[:cooldown].hours
    Time.current - @battle_unit.last_ability_use < cooldown_period
  end

  # Get cooldown remaining for ability
  def cooldown_remaining(ability_key)
    return 0 unless @battle_unit.last_ability_use

    ability = ABILITIES[ability_key]
    cooldown_period = ability[:cooldown].hours
    elapsed = Time.current - @battle_unit.last_ability_use
    remaining = cooldown_period - elapsed

    remaining.positive? ? (remaining / 3600.0).ceil : 0
  end

  private

  # Cavalry Charge - Double damage attack
  def charge_attack(target_units)
    return if target_units.empty?

    target = target_units.first
    damage = calculate_charge_damage(target)
    
    apply_damage(target, damage)
    apply_morale_damage(target, damage / 2)
    
    {
      type: :charge,
      damage: damage,
      morale_damage: damage / 2,
      target: target
    }
  end

  # Arrow Volley - Attack multiple enemies
  def volley_attack(target_units)
    results = []
    
    target_units.each do |target|
      damage = calculate_volley_damage(target)
      apply_damage(target, damage)
      
      results << {
        target: target,
        damage: damage
      }
    end
    
    {
      type: :volley,
      targets: results
    }
  end

  # Shield Wall - Increase defense
  def shield_wall_defense(_target_units)
    @battle_unit.temp_defense_bonus += 20
    @battle_unit.save!
    
    {
      type: :shield_wall,
      defense_bonus: 20,
      duration: 2
    }
  end

  # Artillery Bombardment - Reduce enemy morale
  def bombardment_attack(target_units)
    return if target_units.empty?

    results = []
    
    target_units.each do |target|
      morale_damage = calculate_bombardment_morale_damage(target)
      apply_morale_damage(target, morale_damage)
      
      results << {
        target: target,
        morale_damage: morale_damage
      }
    end
    
    {
      type: :bombardment,
      targets: results
    }
  end

  # Rally Troops - Boost friendly morale
  def rally_morale(target_units)
    results = []
    
    target_units.each do |target|
      next if target.army != @battle_unit.army
      
      morale_boost = calculate_rally_morale_boost(target)
      apply_morale_boost(target, morale_boost)
      
      results << {
        target: target,
        morale_boost: morale_boost
      }
    end
    
    {
      type: :rally,
      targets: results
    }
  end

  # Flanking Maneuver - Bonus damage from side attacks
  def flanking_bonus(target_units)
    return if target_units.empty?

    target = target_units.first
    damage = calculate_flanking_damage(target)
    
    apply_damage(target, damage)
    
    {
      type: :flanking,
      damage: damage,
      target: target
    }
  end

  # Helper methods for damage calculations
  def calculate_charge_damage(target)
    base_damage = @unit.attack * 2
    defense = target.unit.defense + target.temp_defense_bonus
    [base_damage - defense, 1].max
  end

  def calculate_volley_damage(target)
    base_damage = @unit.attack * 0.7
    defense = target.unit.defense + target.temp_defense_bonus
    [base_damage - defense, 1].max
  end

  def calculate_bombardment_morale_damage(target)
    base_morale_damage = 15
    target.unit.morale * 0.1 + base_morale_damage
  end

  def calculate_rally_morale_boost(target)
    base_boost = 20
    [base_boost, 100 - target.morale].min
  end

  def calculate_flanking_damage(target)
    base_damage = @unit.attack * 1.5
    defense = target.unit.defense + target.temp_defense_bonus
    [base_damage - defense, 1].max
  end

  def apply_damage(target, damage)
    target.health = [target.health - damage, 0].max
    target.save!
  end

  def apply_morale_damage(target, morale_damage)
    target.morale = [target.morale - morale_damage, 0].max
    target.save!
  end

  def apply_morale_boost(target, morale_boost)
    target.morale = [target.morale + morale_boost, 100].min
    target.save!
  end
end