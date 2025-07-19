class BattleReplayService
  def initialize(battle)
    @battle = battle
  end

  def record_action(action_type, unit, target = nil, details = {})
    BattleReplay.create!(
      battle: @battle,
      turn_number: @battle.current_turn,
      action_type: action_type,
      unit_id: unit.id,
      target_id: target&.id,
      details: details,
      timestamp: Time.current
    )
  end

  def get_replay_data
    {
      battle: @battle,
      replay_actions: @battle.battle_replays.order(:created_at),
      initial_state: get_initial_state,
      final_state: get_final_state,
      summary: generate_summary
    }
  end

  def play_replay
    replay_data = get_replay_data
    replay_actions = replay_data[:replay_actions]
    
    return { error: "No replay data available" } if replay_actions.empty?

    {
      battle_name: @battle.name,
      total_turns: @battle.current_turn,
      winner: @battle.winner&.name || "Draw",
      actions: replay_actions.map { |action| format_action(action) },
      summary: replay_data[:summary]
    }
  end

  def export_replay
    replay_data = get_replay_data
    
    {
      version: "1.0",
      battle: {
        id: @battle.id,
        name: @battle.name,
        historical_period: @battle.historical_period,
        terrain: @battle.terrain.name,
        armies: @battle.armies.map { |army| { id: army.id, name: army.name } }
      },
      replay: {
        total_turns: @battle.current_turn,
        winner: @battle.winner&.name,
        actions: @battle.battle_replays.order(:created_at).map { |action| export_action(action) }
      },
      metadata: {
        created_at: Time.current,
        duration_seconds: calculate_duration,
        difficulty: @battle.ai_difficulty || "normal"
      }
    }
  end

  private

  def get_initial_state
    {
      units: @battle.battle_units.map do |unit|
        {
          id: unit.id,
          unit_name: unit.unit.name,
          army_name: unit.army.name,
          initial_health: unit.health,
          initial_morale: unit.morale
        }
      end
    }
  end

  def get_final_state
    {
      units: @battle.battle_units.map do |unit|
        {
          id: unit.id,
          final_health: unit.health,
          final_morale: unit.morale,
          status: unit.health > 0 ? "alive" : "defeated"
        }
      end
    }
  end

  def generate_summary
    total_actions = @battle.battle_replays.count
    attack_actions = @battle.battle_replays.where(action_type: 'attack').count
    move_actions = @battle.battle_replays.where(action_type: 'move').count
    special_actions = @battle.battle_replays.where(action_type: 'special_ability').count
    
    {
      total_actions: total_actions,
      attack_actions: attack_actions,
      move_actions: move_actions,
      special_actions: special_actions,
      average_actions_per_turn: total_actions.to_f / [@battle.current_turn, 1].max,
      longest_turn: calculate_longest_turn,
      key_moments: identify_key_moments
    }
  end

  def format_action(action)
    {
      turn: action.turn_number,
      type: action.action_type,
      unit: action.unit&.unit&.name,
      target: action.target&.unit&.name,
      details: action.details,
      timestamp: action.timestamp
    }
  end

  def export_action(action)
    {
      turn: action.turn_number,
      type: action.action_type,
      unit_id: action.unit_id,
      target_id: action.target_id,
      details: action.details,
      timestamp: action.timestamp.iso8601
    }
  end

  def calculate_duration
    first_action = @battle.battle_replays.order(:created_at).first
    last_action = @battle.battle_replays.order(:created_at).last
    
    return 0 unless first_action && last_action
    
    (last_action.created_at - first_action.created_at).to_i
  end

  def calculate_longest_turn
    actions_by_turn = @battle.battle_replays.group(:turn_number).count
    return 0 if actions_by_turn.empty?
    
    actions_by_turn.values.max
  end

  def identify_key_moments
    key_moments = []
    
    # Find turns with significant unit losses
    @battle.battle_replays.where(action_type: 'attack').each do |action|
      if action.details['damage_dealt'] && action.details['damage_dealt'] > 30
        key_moments << {
          type: 'critical_hit',
          turn: action.turn_number,
          description: "Major damage dealt in turn #{action.turn_number}"
        }
      end
    end
    
    # Find morale breaking points
    @battle.battle_replays.where(action_type: 'morale_check').each do |action|
      if action.details['morale_lost'] && action.details['morale_lost'] > 20
        key_moments << {
          type: 'morale_break',
          turn: action.turn_number,
          description: "Significant morale loss in turn #{action.turn_number}"
        }
      end
    end
    
    key_moments.first(5) # Limit to top 5 key moments
  end
end