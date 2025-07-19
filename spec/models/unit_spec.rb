require 'rails_helper'

RSpec.describe Unit, type: :model do
  let(:unit) { create(:unit) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:unit_type) }
    it { should validate_inclusion_of(:unit_type).in_array(%w[infantry cavalry archer artillery support]) }
    it { should validate_presence_of(:attack) }
    it { should validate_presence_of(:defense) }
    it { should validate_presence_of(:health) }
    it { should validate_presence_of(:morale) }
    it { should validate_presence_of(:movement) }
    it { should validate_presence_of(:description) }
    
    it { should validate_numericality_of(:attack).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:defense).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:health).is_greater_than(0) }
    it { should validate_numericality_of(:morale).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:movement).is_greater_than_or_equal_to(0) }
    
    it { should validate_length_of(:name).is_at_most(100) }
    it { should validate_length_of(:unit_type).is_at_most(50) }
  end

  describe 'associations' do
    it { should belong_to(:army) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(unit).to be_valid
    end
  end

  describe 'attributes' do
    it 'has all required attributes' do
      expect(unit).to respond_to(:name)
      expect(unit).to respond_to(:unit_type)
      expect(unit).to respond_to(:attack)
      expect(unit).to respond_to(:defense)
      expect(unit).to respond_to(:health)
      expect(unit).to respond_to(:morale)
      expect(unit).to respond_to(:movement)
      expect(unit).to respond_to(:special_ability)
      expect(unit).to respond_to(:description)
    end
  end

  describe 'unit stats' do
    it 'has reasonable stat ranges' do
      unit = create(:unit, 
        attack: 8,
        defense: 6,
        health: 10,
        morale: 8,
        movement: 4
      )
      
      expect(unit.attack).to eq(8)
      expect(unit.defense).to eq(6)
      expect(unit.health).to eq(10)
      expect(unit.morale).to eq(8)
      expect(unit.movement).to eq(4)
    end

    it 'rejects negative stats' do
      unit = build(:unit, attack: -1)
      expect(unit).not_to be_valid
      expect(unit.errors[:attack]).to include("must be greater than or equal to 0")
    end
  end

  describe 'army association' do
    it 'belongs to an army' do
      army = create(:army)
      unit = create(:unit, army: army)
      
      expect(unit.army).to eq(army)
      expect(army.units).to include(unit)
    end

    it 'requires an army' do
      unit = build(:unit, army: nil)
      expect(unit).not_to be_valid
      expect(unit.errors[:army]).to include("must exist")
    end
  end

  describe 'special abilities' do
    it 'can have special abilities' do
      unit = create(:unit, special_ability: "Shield Wall")
      expect(unit.special_ability).to eq("Shield Wall")
    end

    it 'can be nil for special abilities' do
      unit = create(:unit, special_ability: nil)
      expect(unit.special_ability).to be_nil
    end
  end

  describe 'unit types' do
    it 'supports different unit types' do
      infantry = create(:unit, unit_type: "infantry")
      cavalry = create(:unit, unit_type: "cavalry")
      archer = create(:unit, unit_type: "archer")
      
      expect(infantry.unit_type).to eq("infantry")
      expect(cavalry.unit_type).to eq("cavalry")
      expect(archer.unit_type).to eq("archer")
    end
  end
end
