class DifficultyService
  DIFFICULTY_LEVELS = {
    easy: {
      ai_attack_bonus: -2,
      ai_defense_bonus: -1,
      ai_morale_bonus: -5,
      player_morale_bonus: 5,
      ai_aggression: 0.7,
      description: "Relaxed gameplay with forgiving AI"
    },
    normal: {
      ai_attack_bonus: 0,
      ai_defense_bonus: 0,
      ai_morale_bonus: 0,
      player_morale_bonus: 0,
      ai_aggression: 1.0,
      description: "Balanced gameplay for experienced players"
    },
    hard: {
      ai_attack_bonus: 2,
      ai_defense_bonus: 1,
      ai_morale_bonus: 5,
      player_morale_bonus: -5,
      ai_aggression: 1.3,
      description: "Challenging AI with tactical advantages"
    },
    expert: {
      ai_attack_bonus: 4,
      ai_defense_bonus: 2,
      ai_morale_bonus: 10,
      player_morale_bonus: -10,
      ai_aggression: 1.5,
      description: "Maximum challenge with expert-level AI"
    }
  }.freeze

  def self.get_difficulty_settings(level)
    DIFFICULTY_LEVELS[level.to_sym] || DIFFICULTY_LEVELS[:normal]
  end

  def self.adjust_ai_behavior(battle, difficulty_level)
    settings = get_difficulty_settings(difficulty_level)
    
    battle.update!(
      ai_difficulty: difficulty_level,
      ai_attack_bonus: settings[:ai_attack_bonus],
      ai_defense_bonus: settings[:ai_defense_bonus],
      ai_morale_bonus: settings[:ai_morale_bonus],
      player_morale_bonus: settings[:player_morale_bonus],
      ai_aggression: settings[:ai_aggression]
    )
  end

  def self.available_difficulties
    DIFFICULTY_LEVELS.keys.map(&:to_s)
  end
end