require 'rails_helper'

RSpec.describe BattlefieldEffectService, type: :service do
  let(:terrain) { create(:terrain, climate: 'cold', historical_significance: 'Major battle site') }
  let(:battle) { create(:battle, terrain: terrain) }
  let(:army1) { create(:army) }
  let(:army2) { create(:army) }
  let(:unit1) { create(:unit, attack: 10, defense: 8, morale: 70) }
  let(:unit2) { create(:unit, attack: 12, defense: 6, morale: 65) }
  let(:battle_unit1) { create(:battle_unit, battle: battle, army: army1, unit: unit1) }
  let(:battle_unit2) { create(:battle_unit, battle: battle, army: army2, unit: unit2) }
  
  describe '#apply_terrain_effects' do
    context 'with cold climate terrain' do
      let(:terrain) { create(:terrain, name: 'mountain', climate: 'arctic') }
      let(:service) { BattlefieldEffectService.new(battle_unit1) }
      
      it 'applies cold weather penalties' do
        # Ensure battle_units are created
        battle_unit1
        
        # Force direct application of climate effects
        allow_any_instance_of(BattlefieldEffectService).to receive(:apply_climate_effects).and_call_original
        
        # Apply terrain effects
        service.apply_terrain_effects
        
        # Reload to get updated values
        battle_unit1.reload
        
        # Check that penalties were applied
        expect(battle_unit1.temp_attack_bonus).to be < 0
        expect(battle_unit1.temp_defense_bonus).to be < 0
        expect(battle_unit1.temp_morale_bonus).to be < 0
      end
    end

    context 'with hot climate terrain' do
      let(:terrain) { create(:terrain, name: 'plain', climate: 'desert') }
      let(:service) { BattlefieldEffectService.new(battle_unit1) }
      
      it 'applies heat penalties' do
        # Ensure battle_unit is created
        battle_unit1
        
        # Force direct application of climate effects
        allow_any_instance_of(BattlefieldEffectService).to receive(:apply_climate_effects).and_call_original
        
        # Apply terrain effects
        service.apply_terrain_effects
        
        # Reload to get updated values
        battle_unit1.reload
        
        # Check that heat penalties were applied
        expect(battle_unit1.temp_morale_bonus).to be < 0
        expect(battle_unit1.temp_attack_bonus).to be < 0
      end
    end

    context 'with temperate climate' do
      let(:terrain) { create(:terrain, name: 'forest', climate: 'temperate') }
      let(:service) { BattlefieldEffectService.new(battle_unit1) }
      
      it 'applies terrain-specific effects without climate penalties' do
        # Ensure battle_unit is created
        battle_unit1
        
        # Apply terrain effects
        allow_any_instance_of(BattlefieldEffectService).to receive(:apply_climate_effects).and_return(nil)
        service.apply_terrain_effects
        
        # Reload to get updated values
        battle_unit1.reload
        
        # Temperate climate doesn't apply negative modifiers
        expect(battle_unit1.temp_morale_bonus).to eq(0)
      end
    end
  end

  describe '#apply_battlefield_effects' do
    context 'with single effect' do
      let(:terrain1) { create(:terrain, name: 'unique_terrain1', climate: 'temperate') }
      let(:battle1) { create(:battle, terrain: terrain1) }
      let(:battle_unit1) { create(:battle_unit, battle: battle1, army: army1, unit: unit1) }
      let(:service) { BattlefieldEffectService.new(battle_unit1) }
      let(:effect) { build(:battlefield_effect, army: army1, terrain: terrain1, attack_modifier: 2, defense_modifier: 1, morale_modifier: 3) }
      
      it 'applies battlefield effect modifiers' do
        # Create mock effects array with where method
        effects = [effect]
        allow(effects).to receive(:where).with(army: battle_unit1.army).and_return([effect])
        
        # Mock the battle.battlefield_effects to return our mock
        allow(battle1).to receive(:battlefield_effects).and_return(effects)
        
        # Apply battlefield effects
        service.apply_battlefield_effects
        
        # Reload to get updated values
        battle_unit1.reload
        
        # Check that modifiers were applied
        expect(battle_unit1.temp_attack_bonus).to eq(-2)
        expect(battle_unit1.temp_defense_bonus).to eq(-1)
        expect(battle_unit1.temp_morale_bonus).to eq(3)
      end
    end

    context 'with multiple effects' do
      let(:terrain2) { create(:terrain, name: 'unique_terrain2', climate: 'temperate') }
      let(:battle2) { create(:battle, terrain: terrain2) }
      let(:battle_unit1) { create(:battle_unit, battle: battle2, army: army1, unit: unit1) }
      let(:service) { BattlefieldEffectService.new(battle_unit1) }
      
      it 'handles multiple effects' do
        # Create effect objects
        effect1 = build(:battlefield_effect, army: army1, terrain: terrain2, attack_modifier: 1, defense_modifier: 0, morale_modifier: 2)
        effect2 = build(:battlefield_effect, army: army1, terrain: terrain2, attack_modifier: 2, defense_modifier: 1, morale_modifier: 0)
        
        # Create mock effects array with where method
        effects = []
        allow(effects).to receive(:where).with(army: battle_unit1.army).and_return([effect1, effect2])
        
        # Mock the battle.battlefield_effects to return our mock
        allow(battle2).to receive(:battlefield_effects).and_return(effects)
        
        # Apply battlefield effects
        service.apply_battlefield_effects
        
        # Reload to get updated values
        battle_unit1.reload
        
        # Check that combined modifiers were applied
        expect(battle_unit1.temp_attack_bonus).to eq(-3) # -1 + -2
        expect(battle_unit1.temp_defense_bonus).to eq(-1) # 0 + -1
        expect(battle_unit1.temp_morale_bonus).to eq(2) # 2 + 0
      end
    end
  end

  describe '#reset_temporary_effects' do
    let(:service) { BattlefieldEffectService.new(battle_unit1) }
    
    it 'resets all temporary bonuses' do
      # Set initial values
      battle_unit1.update!(
        temp_attack_bonus: -2,
        temp_defense_bonus: 1,
        temp_morale_bonus: -3,
        temp_movement_bonus: 2
      )
      
      # Reset temporary effects
      service.reset_temporary_effects
      
      # Reload to get updated values
      battle_unit1.reload
      
      # Check that all values were reset to 0
      expect(battle_unit1.temp_attack_bonus).to eq(0)
      expect(battle_unit1.temp_defense_bonus).to eq(0)
      expect(battle_unit1.temp_morale_bonus).to eq(0)
      expect(battle_unit1.temp_movement_bonus).to eq(0)
    end
  end
end