class SpecialAbilityService
  # Define abilities with their effects and requirements
  ABILITIES = {
    charge: {
      name: "Charge",
      description: "A powerful cavalry charge that deals extra damage",
      unit_types: ["cavalry", "heavy cavalry", "knights"],
      cooldown: 2,
      effects: {
        attack_bonus: 15,
        movement_bonus: 2,
        target_morale_penalty: -10
      }
    },
    volley: {
      name: "Volley",
      description: "Coordinated arrow fire that hits multiple targets",
      unit_types: ["archer", "longbowman", "crossbowman"],
      cooldown: 2,
      effects: {
        attack_bonus: 5,
        multi_target: true,
        range_bonus: 1
      }
    },
    shield_wall: {
      name: "Shield Wall",
      description: "Defensive formation that greatly increases defense",
      unit_types: ["infantry", "spearman", "hoplite", "legionary"],
      cooldown: 3,
      effects: {
        defense_bonus: 20,
        movement_penalty: -2,
        morale_bonus: 10
      }
    },
    flanking: {
      name: "Flanking Maneuver",
      description: "Move around enemy lines to attack from the side or rear",
      unit_types: ["light cavalry", "cavalry", "skirmisher"],
      cooldown: 2,
      effects: {
        attack_bonus: 10,
        bypass_defense: true,
        movement_bonus: 1
      }
    },
    rally: {
      name: "Rally",
      description: "Boost morale of nearby friendly units",
      unit_types: ["commander", "officer", "standard bearer"],
      cooldown: 3,
      effects: {
        morale_bonus: 15,
        friendly_only: true,
        area_effect: true
      }
    },
    berserker_rage: {
      name: "Berserker Rage",
      description: "Enter a frenzied state with increased attack but reduced defense",
      unit_types: ["berserker", "warrior", "viking"],
      cooldown: 4,
      effects: {
        attack_bonus: 25,
        defense_penalty: -10,
        morale_penalty: -5
      }
    },
    phalanx: {
      name: "Phalanx Formation",
      description: "Tight formation that increases defense against frontal attacks",
      unit_types: ["spearman", "hoplite", "pikeman"],
      cooldown: 3,
      effects: {
        defense_bonus: 15,
        attack_penalty: -5,
        directional_defense: "front"
      }
    },
    bombardment: {
      name: "Bombardment",
      description: "Long-range artillery attack that can hit multiple targets",
      unit_types: ["artillery", "catapult", "trebuchet"],
      cooldown: 4,
      effects: {
        attack_bonus: 20,
        area_effect: true,
        range_bonus: 2
      }
    }
  }.freeze

  def initialize(battle_unit)
    @battle_unit = battle_unit
    @unit = battle_unit.unit
  end

  # Return all abilities available to this unit type
  def available_abilities
    unit_type = @unit.unit_type.downcase
    
    ABILITIES.select do |_, ability|
      ability[:unit_types].any? { |type| unit_type.include?(type) }
    end
  end

  # Check if the unit can use a specific ability
  def can_use_ability?(ability_key)
    # Check if ability exists and is available for this unit type
    ability = ABILITIES[ability_key]
    return false unless ability
    return false unless available_abilities.key?(ability_key)
    
    # Check if unit is active
    return false unless @battle_unit.active?
    
    # Check cooldown
    if @battle_unit.last_ability_use.present?
      cooldown_turns = ability[:cooldown] || 1
      cooldown_time = cooldown_turns * 1.minute
      return false if @battle_unit.last_ability_use > (Time.current - cooldown_time)
    end
    
    true
  end

  # Use the ability on specified targets
  def use_ability(ability_key, targets)
    return false unless can_use_ability?(ability_key)
    
    ability = ABILITIES[ability_key]
    effects = ability[:effects]
    
    # Record ability use time
    @battle_unit.last_ability_use = Time.current
    @battle_unit.save!
    
    # Apply effects based on ability type
    results = apply_ability_effects(ability_key, effects, targets)
    
    # Return results of ability use
    {
      ability: ability_key,
      ability_name: ability[:name],
      user: @battle_unit,
      targets: targets,
      effects: results,
      timestamp: Time.current
    }
  end

  private

  def apply_ability_effects(ability_key, effects, targets)
    results = []
    
    # Handle different types of abilities
    case ability_key
    when :charge
      results = apply_charge_effects(effects, targets)
    when :volley
      results = apply_volley_effects(effects, targets)
    when :shield_wall
      results = apply_shield_wall_effects(effects, targets)
    when :flanking
      results = apply_flanking_effects(effects, targets)
    when :rally
      results = apply_rally_effects(effects, targets)
    when :berserker_rage
      results = apply_berserker_effects(effects, targets)
    when :phalanx
      results = apply_phalanx_effects(effects, targets)
    when :bombardment
      results = apply_bombardment_effects(effects, targets)
    else
      # Generic ability application
      results = apply_generic_effects(effects, targets)
    end
    
    results
  end

  # Apply charge effects (cavalry ability)
  def apply_charge_effects(effects, target)
    # Ensure target is a single unit or the first of an array
    target = Array(target).first
    return [] unless target
    
    # Apply bonuses to charging unit
    @battle_unit.temp_attack_bonus += effects[:attack_bonus] || 0
    @battle_unit.temp_movement_bonus += effects[:movement_bonus] || 0
    @battle_unit.save!
    
    # Apply morale penalty to target
    if target.respond_to?(:temp_morale_bonus)
      target.temp_morale_bonus += effects[:target_morale_penalty] || 0
      target.save!
    end
    
    [{ target: target, effect: "Charge impact", damage: effects[:attack_bonus] || 0 }]
  end

  # Apply volley effects (archer ability)
  def apply_volley_effects(effects, targets)
    results = []
    
    # Ensure targets is an array
    targets = Array(targets)
    return [] if targets.empty?
    
    # Apply attack bonus to archer unit
    @battle_unit.temp_attack_bonus += effects[:attack_bonus] || 0
    @battle_unit.save!
    
    # Apply damage to each target
    targets.each do |target|
      # Calculate damage based on distance and other factors
      base_damage = effects[:attack_bonus] || 5
      damage = base_damage - rand(0..2) # Add some randomness
      
      results << { target: target, effect: "Arrow volley", damage: damage }
    end
    
    results
  end

  # Apply shield wall effects (infantry ability)
  def apply_shield_wall_effects(effects, targets)
    # Shield wall typically affects the unit itself
    @battle_unit.temp_defense_bonus += effects[:defense_bonus] || 0
    @battle_unit.temp_movement_bonus += effects[:movement_penalty] || 0
    @battle_unit.temp_morale_bonus += effects[:morale_bonus] || 0
    @battle_unit.save!
    
    [{ target: @battle_unit, effect: "Shield Wall formation", defense_bonus: effects[:defense_bonus] || 0 }]
  end

  # Apply flanking effects (light cavalry ability)
  def apply_flanking_effects(effects, target)
    # Ensure target is a single unit or the first of an array
    target = Array(target).first
    return [] unless target
    
    # Apply bonuses to flanking unit
    @battle_unit.temp_attack_bonus += effects[:attack_bonus] || 0
    @battle_unit.temp_movement_bonus += effects[:movement_bonus] || 0
    @battle_unit.save!
    
    # Flanking attacks bypass some defense
    bypass_factor = effects[:bypass_defense] ? 0.5 : 0.0
    
    [{ target: target, effect: "Flanking maneuver", damage: effects[:attack_bonus] || 0, defense_bypass: bypass_factor }]
  end

  # Apply rally effects (commander ability)
  def apply_rally_effects(effects, targets)
    results = []
    
    # Ensure targets is an array
    targets = Array(targets)
    return [] if targets.empty?
    
    # Apply morale bonus to each friendly target
    targets.each do |target|
      if target.army_id == @battle_unit.army_id
        target.temp_morale_bonus += effects[:morale_bonus] || 0
        target.save!
        
        results << { target: target, effect: "Rally", morale_bonus: effects[:morale_bonus] || 0 }
      end
    end
    
    results
  end

  # Apply berserker rage effects
  def apply_berserker_effects(effects, targets)
    # Berserker rage affects the unit itself
    @battle_unit.temp_attack_bonus += effects[:attack_bonus] || 0
    @battle_unit.temp_defense_bonus += effects[:defense_penalty] || 0
    @battle_unit.temp_morale_bonus += effects[:morale_penalty] || 0
    @battle_unit.save!
    
    [{ target: @battle_unit, effect: "Berserker Rage", attack_bonus: effects[:attack_bonus] || 0 }]
  end

  # Apply phalanx formation effects
  def apply_phalanx_effects(effects, targets)
    # Phalanx affects the unit itself
    @battle_unit.temp_defense_bonus += effects[:defense_bonus] || 0
    @battle_unit.temp_attack_bonus += effects[:attack_penalty] || 0
    @battle_unit.save!
    
    [{ target: @battle_unit, effect: "Phalanx Formation", defense_bonus: effects[:defense_bonus] || 0 }]
  end

  # Apply bombardment effects (artillery ability)
  def apply_bombardment_effects(effects, targets)
    results = []
    
    # Ensure targets is an array
    targets = Array(targets)
    return [] if targets.empty?
    
    # Apply attack bonus to artillery unit
    @battle_unit.temp_attack_bonus += effects[:attack_bonus] || 0
    @battle_unit.save!
    
    # Apply damage to each target in the area
    targets.each do |target|
      # Calculate damage based on distance and other factors
      base_damage = effects[:attack_bonus] || 15
      
      # Randomize damage slightly for each target
      damage = base_damage - rand(0..5)
      
      results << { target: target, effect: "Artillery bombardment", damage: damage }
    end
    
    results
  end

  # Apply generic ability effects
  def apply_generic_effects(effects, targets)
    results = []
    
    # Apply effects to the unit itself
    @battle_unit.temp_attack_bonus += effects[:attack_bonus] || 0
    @battle_unit.temp_defense_bonus += effects[:defense_bonus] || 0
    @battle_unit.temp_morale_bonus += effects[:morale_bonus] || 0
    @battle_unit.temp_movement_bonus += effects[:movement_bonus] || 0
    @battle_unit.save!
    
    # Apply effects to targets if applicable
    if targets.present? && !effects[:friendly_only]
      targets = Array(targets)
      
      targets.each do |target|
        results << { target: target, effect: "Ability effect", damage: effects[:attack_bonus] || 0 }
      end
    end
    
    results
  end
end
