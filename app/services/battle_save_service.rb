class BattleSaveService
  def initialize(battle)
    @battle = battle
  end

  def save_battle_state
    return false unless @battle.persisted?

    battle_state = {
      battle_id: @battle.id,
      current_turn: @battle.current_turn,
      status: @battle.status,
      winner_id: @battle.winner_id,
      outcome: @battle.outcome,
      units: serialize_units,
      armies: serialize_armies,
      terrain: serialize_terrain,
      timestamp: Time.current,
      version: '1.0'
    }

    # Save to file or database
    save_to_storage(battle_state)
  end

  def load_battle_state(state_data)
    return false unless valid_state?(state_data)

    ActiveRecord::Base.transaction do
      # Update battle state
      @battle.update!(
        current_turn: state_data[:current_turn],
        status: state_data[:status],
        winner_id: state_data[:winner_id],
        outcome: state_data[:outcome]
      )

      # Restore units
      restore_units(state_data[:units])

      # Restore armies
      restore_armies(state_data[:armies])

      true
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to load battle state: #{e.message}"
    false
  end

  def export_battle_state
    state = save_battle_state
    return nil unless state

    {
      battle: @battle.as_json(include: [:terrain, :armies, :battle_units]),
      state: state
    }
  end

  def import_battle_state(import_data)
    return false unless valid_import?(import_data)

    ActiveRecord::Base.transaction do
      # Create or update battle
      battle_data = import_data[:battle]
      state_data = import_data[:state]

      battle = Battle.find_or_create_by(id: battle_data['id']) do |b|
        b.assign_attributes(battle_data.except('id', 'terrain', 'armies', 'battle_units'))
      end

      # Import terrain
      terrain_data = battle_data['terrain']
      terrain = Terrain.find_or_create_by(id: terrain_data['id']) do |t|
        t.assign_attributes(terrain_data.except('id'))
      end
      battle.update!(terrain: terrain)

      # Import armies
      battle_data['armies'].each do |army_data|
        army = Army.find_or_create_by(id: army_data['id']) do |a|
          a.assign_attributes(army_data.except('id'))
        end
      end

      # Import battle units
      battle_data['battle_units'].each do |unit_data|
        unit = Unit.find_or_create_by(id: unit_data['unit_id'])
        army = Army.find(unit_data['army_id'])
        
        BattleUnit.find_or_create_by(
          battle: battle,
          army: army,
          unit: unit
        ) do |bu|
          bu.assign_attributes(unit_data.except('id', 'battle_id', 'army_id', 'unit_id'))
        end
      end

      # Load state
      service = BattleSaveService.new(battle)
      service.load_battle_state(state_data)
    end
  end

  private

  def serialize_units
    @battle.battle_units.includes(:unit, :army).map do |battle_unit|
      {
        id: battle_unit.id,
        unit_id: battle_unit.unit_id,
        army_id: battle_unit.army_id,
        health: battle_unit.health,
        morale: battle_unit.morale,
        position_x: battle_unit.position_x,
        position_y: battle_unit.position_y,
        temp_attack_bonus: battle_unit.temp_attack_bonus,
        temp_defense_bonus: battle_unit.temp_defense_bonus,
        temp_morale_bonus: battle_unit.temp_morale_bonus,
        temp_movement_bonus: battle_unit.temp_movement_bonus
      }
    end
  end

  def serialize_armies
    @battle.armies.map do |army|
      {
        id: army.id,
        name: army.name,
        description: army.description,
        historical_period: army.historical_period
      }
    end
  end

  def serialize_terrain
    terrain = @battle.terrain
    {
      id: terrain.id,
      name: terrain.name,
      description: terrain.description,
      climate: terrain.climate,
      historical_significance: terrain.historical_significance
    }
  end

  def save_to_storage(state)
    # Save to database
    BattleState.create!(
      battle: @battle,
      state_data: state.to_json,
      created_at: Time.current
    )
  end

  def restore_units(units_data)
    units_data.each do |unit_data|
      battle_unit = BattleUnit.find(unit_data[:id])
      battle_unit.update!(
        health: unit_data[:health],
        morale: unit_data[:morale],
        position_x: unit_data[:position_x],
        position_y: unit_data[:position_y],
        temp_attack_bonus: unit_data[:temp_attack_bonus],
        temp_defense_bonus: unit_data[:temp_defense_bonus],
        temp_morale_bonus: unit_data[:temp_morale_bonus],
        temp_movement_bonus: unit_data[:temp_movement_bonus]
      )
    end
  end

  def restore_armies(armies_data)
    armies_data.each do |army_data|
      army = Army.find(army_data[:id])
      army.update!(
        name: army_data[:name],
        description: army_data[:description],
        historical_period: army_data[:historical_period]
      )
    end
  end

  def valid_state?(state_data)
    return false unless state_data.is_a?(Hash)
    return false unless state_data[:battle_id].present?
    return false unless state_data[:units].is_a?(Array)
    return false unless state_data[:version] == '1.0'
    
    true
  end

  def valid_import?(import_data)
    return false unless import_data.is_a?(Hash)
    return false unless import_data[:battle].present?
    return false unless import_data[:state].present?
    
    true
  end
end

# Model for storing battle states
class BattleState < ApplicationRecord
  belongs_to :battle
  
  validates :state_data, presence: true
  validates :battle_id, uniqueness: true
end