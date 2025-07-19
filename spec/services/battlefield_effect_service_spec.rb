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
  
  let(:service) { BattlefieldEffectService.new(battle) }

  describe '#apply_terrain_effects' do
    context 'with cold climate terrain' do
      let(:terrain) { create(:terrain, climate: 'cold') }
      
      it 'applies cold weather penalties' do
        battle_unit1
        battle_unit2
        
        service.apply_terrain_effects
        
        battle_unit1.reload
        battle_unit2.reload
        
        expect(battle_unit1.temp_attack_bonus).to be < 0
        expect(battle_unit1.temp_defense_bonus).to be < 0
        expect(battle_unit1.temp_morale_bonus).to be < 0
      end
    end

    context 'with hot climate terrain' do
      let(:terrain) { create(:terrain, climate: 'hot') }
      
      it 'applies heat penalties' do
        battle_unit1
        battle_unit2
        
        service.apply_terrain_effects
        
        battle_unit1.reload
        expect(battle_unit1.temp_morale_bonus).to be < 0
      end
    end

    context 'with temperate climate' do
      let(:terrain) { create(:terrain, climate: 'temperate') }
      
      it 'applies no penalties' do
        battle_unit1
        battle_unit2
        
        service.apply_terrain_effects
        
        battle_unit1.reload
        expect(battle_unit1.temp_attack_bonus).to eq(0)
        expect(battle_unit1.temp_defense_bonus).to eq(0)
        expect(battle_unit1.temp_morale_bonus).to eq(0)
      end
    end
  end

  describe '#apply_battlefield_effects' do
    let(:effect) { create(:battlefield_effect, name: 'Heavy Rain', attack_modifier: -2, defense_modifier: -1, morale_modifier: -3) }
    
    it 'applies battlefield effect modifiers' do
      battle.battlefield_effects << effect
      battle_unit1
      
      service.apply_battlefield_effects
      
      battle_unit1.reload
      expect(battle_unit1.temp_attack_bonus).to eq(-2)
      expect(battle_unit1.temp_defense_bonus).to eq(-1)
      expect(battle_unit1.temp_morale_bonus).to eq(-3)
    end

    it 'handles multiple effects' do
      effect1 = create(:battlefield_effect, attack_modifier: -1, defense_modifier: 0, morale_modifier: -2)
      effect2 = create(:battlefield_effect, attack_modifier: -2, defense_modifier: -1, morale_modifier: 0)
      
      battle.battlefield_effects << [effect1, effect2]
      battle_unit1
      
      service.apply_battlefield_effects
      
      battle_unit1.reload
      expect(battle_unit1.temp_attack_bonus).to eq(-3) # -1 + -2
      expect(battle_unit1.temp_defense_bonus).to eq(-1) # 0 + -1
      expect(battle_unit1.temp_morale_bonus).to eq(-2) # -2 + 0
    end
  end

  describe '#reset_temporary_effects' do
    it 'resets all temporary bonuses' do
      battle_unit1.update!(
        temp_attack_bonus: -2,
        temp_defense_bonus: 1,
        temp_morale_bonus: -3,
        temp_movement_bonus: 0
      )
      
      service.reset_temporary_effects
      
      battle_unit1.reload
      expect(battle_unit1.temp_attack_bonus).to eq(0)
      expect(battle_unit1.temp_defense_bonus).to eq(0)
      expect(battle_unit1.temp_morale_bonus).to eq(0)
      expect(battle_unit1.temp_movement_bonus).to eq(0)
    end
  end
end