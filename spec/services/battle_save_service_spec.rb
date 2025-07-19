require 'rails_helper'

RSpec.describe BattleSaveService, type: :service do
  let(:terrain) { create(:terrain) }
  let(:battle) { create(:battle, terrain: terrain, current_turn: 5) }
  let(:army1) { create(:army) }
  let(:army2) { create(:army) }
  let(:unit1) { create(:unit) }
  let(:unit2) { create(:unit) }
  let(:battle_unit1) { create(:battle_unit, battle: battle, army: army1, unit: unit1, health: 75, morale: 80) }
  let(:battle_unit2) { create(:battle_unit, battle: battle, army: army2, unit: unit2, health: 90, morale: 95) }
  
  let(:service) { BattleSaveService.new(battle) }

  describe '#save_battle_state' do
    before do
      battle_unit1
      battle_unit2
    end

    it 'saves the battle state successfully' do
      expect(service.save_battle_state).to be_truthy
      
      battle_state = BattleState.last
      expect(battle_state.battle).to eq(battle)
      expect(battle_state.state_hash[:battle_id]).to eq(battle.id)
      expect(battle_state.state_hash[:current_turn]).to eq(5)
    end

    it 'includes all battle units in the state' do
      service.save_battle_state
      
      battle_state = BattleState.last
      units = battle_state.state_hash[:units]
      
      expect(units.count).to eq(2)
      expect(units.first[:health]).to eq(75)
      expect(units.first[:morale]).to eq(80)
    end

    it 'includes terrain and army information' do
      service.save_battle_state
      
      battle_state = BattleState.last
      expect(battle_state.state_hash[:terrain][:id]).to eq(terrain.id)
      expect(battle_state.state_hash[:armies].count).to eq(2)
    end
  end

  describe '#load_battle_state' do
    let(:state_data) do
      {
        battle_id: battle.id,
        current_turn: 7,
        status: 'in_progress',
        winner_id: nil,
        outcome: nil,
        units: [
          {
            id: battle_unit1.id,
            unit_id: unit1.id,
            army_id: army1.id,
            health: 50,
            morale: 60,
            position_x: 1,
            position_y: 1,
            temp_attack_bonus: 2,
            temp_defense_bonus: 1,
            temp_morale_bonus: 0,
            temp_movement_bonus: 0
          }
        ],
        armies: [
          { id: army1.id, name: army1.name, description: army1.description, historical_period: army1.era }
        ],
        terrain: {
          id: terrain.id,
          name: terrain.name,
          description: terrain.description,
          climate: terrain.climate,
          historical_significance: terrain.historical_significance
        },
        timestamp: Time.current,
        version: '1.0'
      }
    end

    it 'loads the battle state successfully' do
      expect(service.load_battle_state(state_data)).to be_truthy
      
      battle.reload
      expect(battle.current_turn).to eq(7)
    end

    it 'updates battle unit states' do
      service.load_battle_state(state_data)
      
      battle_unit1.reload
      expect(battle_unit1.health).to eq(50)
      expect(battle_unit1.morale).to eq(60)
    end
  end

  describe '#export_battle_state' do
    before do
      battle_unit1
      battle_unit2
    end

    it 'exports complete battle state' do
      export = service.export_battle_state
      
      expect(export).to be_a(Hash)
      expect(export[:battle]).to be_present
      expect(export[:state]).to be_present
    end
  end
end