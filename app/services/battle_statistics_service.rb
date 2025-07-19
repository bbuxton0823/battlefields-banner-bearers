class BattleStatisticsService
  def self.for_battle(battle)
    new(battle).generate
  end

  def initialize(battle)
    @battle = battle
  end

  def generate
    {
      battle_summary: battle_summary,
      army_performance: army_performance,
      unit_statistics: unit_statistics,
      turn_analysis: turn_analysis,
      educational_insights: educational_insights
    }
  end

  private

  def battle_summary
    {
      name: @battle.name,
      winner: @battle.winner&.name || "Undecided",
      duration: @battle.current_turn,
      status: @battle.status,
      difficulty: @battle.difficulty_level || "Normal",
      terrain: @battle.terrain.name,
      total_units: @battle.battle_units.count,
      units_lost: @battle.battle_units.where('current_health <= 0').count
    }
  end

  def army_performance
    attacking_army = @battle.attacking_army
    defending_army = @battle.defending_army
    
    {
      attacking: {
        name: attacking_army.name,
        units_deployed: @battle.battle_units.joins(:unit).where(units: { army_id: attacking_army.id }).count,
        units_lost: @battle.battle_units.joins(:unit).where(units: { army_id: attacking_army.id }).where('current_health <= 0').count,
        total_damage_dealt: calculate_total_damage(attacking_army),
        total_damage_received: calculate_total_damage_received(attacking_army),
        morale_average: calculate_morale_average(attacking_army)
      },
      defending: {
        name: defending_army.name,
        units_deployed: @battle.battle_units.joins(:unit).where(units: { army_id: defending_army.id }).count,
        units_lost: @battle.battle_units.joins(:unit).where(units: { army_id: defending_army.id }).where('current_health <= 0').count,
        total_damage_dealt: calculate_total_damage(defending_army),
        total_damage_received: calculate_total_damage_received(defending_army),
        morale_average: calculate_morale_average(defending_army)
      }
    }
  end

  def unit_statistics
    @battle.battle_units.includes(:unit).map do |battle_unit|
      {
        name: battle_unit.unit.name,
        army: battle_unit.unit.army.name,
        initial_health: battle_unit.unit.health,
        current_health: battle_unit.current_health,
        health_percentage: (battle_unit.current_health.to_f / battle_unit.unit.health * 100).round(1),
        initial_morale: battle_unit.unit.morale,
        current_morale: battle_unit.current_morale,
        morale_percentage: (battle_unit.current_morale.to_f / battle_unit.unit.morale * 100).round(1),
        status: battle_unit.current_health > 0 ? "Active" : "Eliminated",
        special_ability_used: battle_unit.special_ability_used || false
      }
    end
  end

  def turn_analysis
    return [] unless @battle.battle_replays.any?
    
    @battle.battle_replays.order(:turn_number).map do |replay|
      {
        turn: replay.turn_number,
        events: replay.battle_events.count,
        key_moments: replay.battle_events.where(event_type: ['victory', 'defeat', 'morale_break']).count,
        educational_unlocks: replay.battle_events.where(event_type: 'educational').count
      }
    end
  end

  def educational_insights
    events = @battle.battle_replays.joins(:battle_events).where(battle_events: { event_type: 'educational' })
    
    {
      total_facts_unlocked: events.count,
      categories: categorize_educational_content(events),
      historical_accuracy_score: calculate_historical_accuracy
    }
  end

  private

  def calculate_total_damage(army)
    # This would need to be implemented based on actual damage tracking
    # For now, return a placeholder
    rand(100..500)
  end

  def calculate_total_damage_received(army)
    # This would need to be implemented based on actual damage tracking
    # For now, return a placeholder
    rand(50..400)
  end

  def calculate_morale_average(army)
    units = @battle.battle_units.joins(:unit).where(units: { army_id: army.id })
    return 0 if units.empty?
    
    (units.average(:current_morale) || 0).round(1)
  end

  def categorize_educational_content(events)
    categories = {
      tactics: 0,
      history: 0,
      geography: 0,
      culture: 0
    }
    
    # This would need actual categorization logic
    categories
  end

  def calculate_historical_accuracy
    # Placeholder for historical accuracy scoring
    rand(85..100)
  end
end