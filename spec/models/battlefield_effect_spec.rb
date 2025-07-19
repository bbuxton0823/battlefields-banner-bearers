require 'rails_helper'

RSpec.describe BattlefieldEffect, type: :model do
  let(:battlefield_effect) { create(:battlefield_effect) }

  describe 'validations' do
    it { should validate_presence_of(:description) }
    
    it { should validate_numericality_of(:heat_penalty).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:mobility_penalty).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:visibility_penalty).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:disease_risk).is_greater_than_or_equal_to(0) }
    
    it { should validate_length_of(:description).is_at_most(500) }
  end

  describe 'associations' do
    it { should belong_to(:terrain) }
    it { should belong_to(:army) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(battlefield_effect).to be_valid
    end
  end

  describe 'attributes' do
    it 'has all required attributes' do
      expect(battlefield_effect).to respond_to(:terrain_id)
      expect(battlefield_effect).to respond_to(:army_id)
      expect(battlefield_effect).to respond_to(:heat_penalty)
      expect(battlefield_effect).to respond_to(:mobility_penalty)
      expect(battlefield_effect).to respond_to(:visibility_penalty)
      expect(battlefield_effect).to respond_to(:disease_risk)
      expect(battlefield_effect).to respond_to(:morale_modifier)
      expect(battlefield_effect).to respond_to(:description)
    end
  end

  describe 'environmental penalties' do
    it 'can store various penalties' do
      effect = create(:battlefield_effect,
        heat_penalty: 5,
        mobility_penalty: 3,
        visibility_penalty: 2,
        disease_risk: 1,
        morale_modifier: -2
      )
      
      expect(effect.heat_penalty).to eq(5)
      expect(effect.mobility_penalty).to eq(3)
      expect(effect.visibility_penalty).to eq(2)
      expect(effect.disease_risk).to eq(1)
      expect(effect.morale_modifier).to eq(-2)
    end

    it 'allows zero penalties' do
      effect = create(:battlefield_effect,
        heat_penalty: 0,
        mobility_penalty: 0,
        visibility_penalty: 0,
        disease_risk: 0,
        morale_modifier: 0
      )
      
      expect(effect).to be_valid
    end

    it 'rejects negative penalties' do
      effect = build(:battlefield_effect, heat_penalty: -1)
      expect(effect).not_to be_valid
      expect(effect.errors[:heat_penalty]).to include("must be greater than or equal to 0")
    end
  end

  describe 'morale modifiers' do
    it 'can have positive morale modifiers' do
      effect = create(:battlefield_effect, morale_modifier: 3)
      expect(effect.morale_modifier).to eq(3)
    end

    it 'can have negative morale modifiers' do
      effect = create(:battlefield_effect, morale_modifier: -4)
      expect(effect.morale_modifier).to eq(-4)
    end
  end

  describe 'associations' do
    it 'belongs to both terrain and army' do
      terrain = create(:terrain)
      army = create(:army)
      effect = create(:battlefield_effect, terrain: terrain, army: army)
      
      expect(effect.terrain).to eq(terrain)
      expect(effect.army).to eq(army)
      expect(terrain.battlefield_effects).to include(effect)
      expect(army.battlefield_effects).to include(effect)
    end

    it 'requires both terrain and army' do
      effect = build(:battlefield_effect, terrain: nil, army: nil)
      expect(effect).not_to be_valid
      expect(effect.errors[:terrain]).to include("must exist")
      expect(effect.errors[:army]).to include("must exist")
    end
  end

  describe 'unique combinations' do
    it 'prevents duplicate terrain-army combinations' do
      terrain = create(:terrain)
      army = create(:army)
      
      create(:battlefield_effect, terrain: terrain, army: army)
      duplicate = build(:battlefield_effect, terrain: terrain, army: army)
      
      expect(duplicate).not_to be_valid
    end
  end

  describe 'descriptive text' do
    it 'provides contextual descriptions' do
      effect = create(:battlefield_effect,
        description: "Roman legions suffer -3 mobility in muddy conditions due to heavy armor"
      )
      
      expect(effect.description).to include("Roman legions")
      expect(effect.description).to include("-3 mobility")
    end
  end
end
