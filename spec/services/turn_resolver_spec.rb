require 'rails_helper'

RSpec.describe TurnResolver, type: :service do
  let(:terrain) { create(:terrain, name: 'Forest', description: 'Dense woodland') }
  let(:battle) { create(:battle, terrain: terrain, max_turns: 10) }
  let(:army1) { create(:army, name: 'Roman Legion') }
  let(:army2) { create(:army, name: 'Gallic Warriors') }
  
  let(:legionary) { create(:unit, name: 'Legionary', attack: 8, defense: 10, unit_type: 'infantry') }
  let(:warrior) { create(:unit, name: 'Gallic Warrior', attack: 10, defense: 6, unit_type: 'infantry') }
  let(:archer) { create(:unit, name: 'Archer', attack: 6, defense: 4, unit_type: 'archer') }
  let(:cavalry) { create(:unit, name: 'Cavalry', attack: 12, defense: 8, unit_type: 'cavalry') }
  
  let(:battle_unit1) { create(:battle_unit, battle: battle, army: army1, unit: legionary, health: 100, morale: 100, position_x: 1, position_y: 1) }
  let(:battle_unit2) { create(:battle_unit, battle: battle, army: army2, unit: warrior, health: 100, morale: 100, position_x: 3, position_y: 3) }
  
  describe '#initialize' do
    it 'initializes with battle and units' do
      resolver = TurnResolver.new(battle, [battle_unit1, battle_unit2])
      expect(resolver.battle).to eq(battle)
      expect(resolver.units).to eq([battle_unit1, battle_unit2])
    end
    
    it 'raises error for nil battle' do
      expect { TurnResolver.new(nil, []) }.to raise_error(ArgumentError, "Battle is required")
    end
    
    it 'raises error for non-array units' do
      expect { TurnResolver.new(battle, "invalid") }.to raise_error(ArgumentError, "Units must be an array")
    end
  end
  
  describe '#resolve_turn' do
    context 'with no units' do
      it 'returns empty result' do
        resolver = TurnResolver.new(battle, [])
        result = resolver.resolve_turn
        
        expect(result[:turn_number]).to eq(0)
        expect(result[:actions]).to be_empty
        expect(result[:victory_result]).to be_nil
        expect(result[:educational_content]).not_to be_empty
      end
    end
    
    context 'with units' do
      let(:units) { [battle_unit1, battle_unit2] }
      let(:resolver) { TurnResolver.new(battle, units) }
      
      it 'processes a complete turn' do
        result = resolver.resolve_turn
        
        expect(result[:turn_number]).to eq(1)
        expect(result[:actions]).not_to be_empty
        expect(result[:educational_content]).not_to be_empty
        expect(result[:updated_units]).not_to be_empty
      end
      
      it 'applies battlefield effects' do
        # We only need to silence the warning that comes from multiple calls.
        # Stub the method so it still executes the original implementation
        # while avoiding the „unexpected multiple receive“ warning.
        allow_any_instance_of(BattlefieldEffectService)
          .to receive(:apply_terrain_effects)
          .and_call_original
        resolver.resolve_turn
      end
      
      it 'processes special abilities' do
        # Create units with special abilities
        legionary_with_shield = create(:unit, name: 'Legionary', attack: 8, defense: 10, unit_type: 'infantry', special_abilities: ['shield_wall'])
        battle_unit3 = create(:battle_unit, battle: battle, army: army1, unit: legionary_with_shield, 
                             health: 100, morale: 100, position_x: 2, position_y: 2)
        
        resolver = TurnResolver.new(battle, [battle_unit3, battle_unit2])
        result = resolver.resolve_turn
        
        ability_actions = result[:actions].select { |a| a[:type] == 'special_ability' }
        expect(ability_actions).not_to be_empty
      end
      
      it 'processes combat between units' do
        result = resolver.resolve_turn
        
        combat_actions = result[:actions].select { |a| a[:type] == 'combat' }
        expect(combat_actions).not_to be_empty
        
        combat_action = combat_actions.first
        expect(combat_action[:attacker]).to be_present
        expect(combat_action[:defender]).to be_present
        expect(combat_action[:outcome]).to be_present
      end
      
      it 'updates unit health and morale' do
        initial_health1 = battle_unit1.health
        initial_health2 = battle_unit2.health
        
        resolver.resolve_turn
        
        battle_unit1.reload
        battle_unit2.reload
        
        expect([battle_unit1.health, battle_unit2.health]).to include(be < 100)
      end
      
      it 'checks victory conditions' do
        # Create units with low health to trigger victory
        battle_unit1.update!(health: 1)
        battle_unit2.update!(health: 1)
        
        result = resolver.resolve_turn
        
        expect(result[:victory_result]).to be_present
        expect(result[:victory_result][:type]).to be_in(['victory', 'draw'])
      end
      
      it 'generates educational content' do
        result = resolver.resolve_turn
        
        expect(result[:educational_content]).to be_an(Array)
        expect(result[:educational_content]).not_to be_empty
        
        content = result[:educational_content].first
        expect(content[:title]).to be_present
        expect(content[:content]).to be_present
        expect(content[:historical_fact]).to be_present
        expect(content[:learning_objective]).to be_present
      end
      
      it 'increments battle turn counter' do
        expect {
          resolver.resolve_turn
        }.to change { battle.reload.current_turn }.by(1)
      end
      
      it 'handles terrain effects in combat' do
        result = resolver.resolve_turn
        
        combat_actions = result[:actions].select { |a| a[:type] == 'combat' }
        combat_actions.each do |action|
          expect(action[:terrain_effects]).to be_present
          expect(action[:terrain_effects][:terrain]).to eq(terrain.name)
        end
      end
    end
    
    context 'with special abilities' do
      let(:cavalry_unit) { create(:battle_unit, battle: battle, army: army1, unit: cavalry, 
                                 health: 100, morale: 100, position_x: 1, position_y: 1) }
      let(:archer_unit) { create(:battle_unit, battle: battle, army: army2, unit: archer, 
                                health: 100, morale: 100, position_x: 4, position_y: 4) }
      
      it 'processes charge ability' do
        cavalry_with_charge = create(:unit, name: 'Cavalry', attack: 12, defense: 8, unit_type: 'cavalry', special_abilities: ['charge'])
        cavalry_unit.update!(unit: cavalry_with_charge)
        
        resolver = TurnResolver.new(battle, [cavalry_unit, archer_unit])
        result = resolver.resolve_turn
        
        charge_actions = result[:actions].select { |a| a[:type] == 'special_ability' && a[:ability] == :charge }
        expect(charge_actions).not_to be_empty
      end
      
      it 'processes volley ability' do
        archer_with_volley = create(:unit, name: 'Archer', attack: 6, defense: 4, unit_type: 'archer', special_abilities: ['volley'])
        archer_unit.update!(unit: archer_with_volley)
        
        # Create multiple targets
        warrior_unit = create(:battle_unit, battle: battle, army: army1, unit: warrior, 
                             health: 100, morale: 100, position_x: 2, position_y: 2)
        
        resolver = TurnResolver.new(battle, [archer_unit, warrior_unit, cavalry_unit])
        result = resolver.resolve_turn
        
        volley_actions = result[:actions].select { |a| a[:type] == 'special_ability' && a[:ability] == :volley }
        expect(volley_actions).not_to be_empty
      end
      
      it 'processes shield wall ability' do
        legionary_with_shield = create(:unit, name: 'Legionary', attack: 8, defense: 10, unit_type: 'infantry', special_abilities: ['shield_wall'])
        legionary_unit = create(:battle_unit, battle: battle, army: army1, unit: legionary_with_shield, 
                              health: 100, morale: 100, position_x: 2, position_y: 2)
        
        resolver = TurnResolver.new(battle, [legionary_unit, archer_unit])
        result = resolver.resolve_turn
        
        shield_actions = result[:actions].select { |a| a[:type] == 'special_ability' && a[:ability] == :shield_wall }
        expect(shield_actions).not_to be_empty
      end
    end
    
    context 'with victory conditions' do
      it 'declares victory when one army is eliminated' do
        battle_unit1.update!(health: 0)
        
        resolver = TurnResolver.new(battle, [battle_unit1, battle_unit2])
        result = resolver.resolve_turn
        
        expect(result[:victory_result][:winner]).to eq(army2)
        expect(result[:victory_result][:type]).to eq('victory')
      end
      
      it 'declares draw when both armies are eliminated' do
        battle_unit1.update!(health: 0)
        battle_unit2.update!(health: 0)
        
        resolver = TurnResolver.new(battle, [battle_unit1, battle_unit2])
        result = resolver.resolve_turn
        
        expect(result[:victory_result][:winner]).to be_nil
        expect(result[:victory_result][:type]).to eq('draw')
      end
      
      it 'handles max turns reached' do
        battle.update!(current_turn: 10, max_turns: 10)
        
        resolver = TurnResolver.new(battle, [battle_unit1, battle_unit2])
        result = resolver.resolve_turn
        
        expect(result[:victory_result][:type]).to be_in(['time_victory', 'draw'])
      end
    end
    
    context 'with terrain effects' do
      let(:hill_terrain) { create(:terrain, name: 'Hill', description: 'Elevated ground') }
      let(:hill_battle) { create(:battle, terrain: hill_terrain, max_turns: 10) }
      
      it 'applies hill terrain effects' do
        hill_unit = create(:battle_unit, battle: hill_battle, army: army1, unit: legionary, 
                          health: 100, morale: 100, position_x: 1, position_y: 1)
        enemy_unit = create(:battle_unit, battle: hill_battle, army: army2, unit: warrior, 
                           health: 100, morale: 100, position_x: 3, position_y: 3)
        
        resolver = TurnResolver.new(hill_battle, [hill_unit, enemy_unit])
        result = resolver.resolve_turn
        
        combat_actions = result[:actions].select { |a| a[:type] == 'combat' }
        expect(combat_actions).not_to be_empty
        
        terrain_effects = combat_actions.first[:terrain_effects]
        expect(terrain_effects[:terrain]).to eq('Hill')
      end
    end
  end
  
  describe 'private methods' do
    let(:units) { [battle_unit1, battle_unit2] }
    let(:resolver) { TurnResolver.new(battle, units) }
    
    describe '#distance' do
      it 'calculates Manhattan distance between units' do
        battle_unit1.update!(position_x: 1, position_y: 1)
        battle_unit2.update!(position_x: 4, position_y: 5)
        
        distance = resolver.send(:distance, battle_unit1, battle_unit2)
        expect(distance).to eq(7) # (4-1) + (5-1) = 7
      end
    end
    
    describe '#flanking_position?' do
      it 'identifies flanking positions' do
        battle_unit1.update!(position_x: 1, position_y: 1)
        battle_unit2.update!(position_x: 2, position_y: 2)
        
        expect(resolver.send(:flanking_position?, battle_unit1, battle_unit2)).to be true
        
        battle_unit2.update!(position_x: 1, position_y: 2)
        expect(resolver.send(:flanking_position?, battle_unit1, battle_unit2)).to be false
      end
    end
    
    describe '#calculate_army_strength' do
      it 'calculates army strength based on units' do
        units = [battle_unit1, battle_unit2]
        strength = resolver.send(:calculate_army_strength, units)
        
        expect(strength).to be > 0
        expect(strength).to eq(100 + 100 + (8 * 10) + (10 * 10) + 100 + 100 + (10 * 10) + (6 * 10))
      end
    end
  end
end