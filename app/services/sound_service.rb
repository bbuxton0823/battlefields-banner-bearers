class SoundService
  def initialize(battle)
    @battle = battle
  end

  def self.sound_for_action(action_type)
    case action_type
    when 'battle_start'
      'battle_start.mp3'
    when 'unit_move'
      'unit_move.mp3'
    when 'unit_attack'
      'unit_attack.mp3'
    when 'unit_defend'
      'unit_defend.mp3'
    when 'unit_death'
      'unit_death.mp3'
    when 'victory'
      'victory.mp3'
    when 'defeat'
      'victory.mp3'
    when 'ambient_battle'
      'ambient_battle.mp3'
    when 'ambient_cold'
      'ambient_cold.mp3'
    when 'ambient_hot'
      'ambient_hot.mp3'
    when 'rain'
      'rain.mp3'
    when 'snow'
      'snow.mp3'
    when 'wind'
      'wind.mp3'
    end
  end

  def self.ambient_for_terrain(terrain_climate)
    case terrain_climate
    when 'cold'
      'ambient_cold'
    when 'hot'
      'ambient_hot'
    else
      'ambient_battle'
    end
  end

  def self.weather_sounds(battlefield_effects)
    battlefield_effects.map do |effect|
      case effect.name.downcase
      when /rain/
        'rain'
      when /snow/
        'snow'
      else
        nil
      end
    end.compact
  end
end