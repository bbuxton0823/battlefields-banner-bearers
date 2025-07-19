require 'rails_helper'

RSpec.describe Army, type: :model do
  let(:army) { create(:army) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:era) }
    it { should validate_presence_of(:core_stat) }
    it { should validate_presence_of(:factual_basis) }
    it { should validate_presence_of(:description) }
    
    it { should validate_length_of(:name).is_at_most(100) }
    it { should validate_length_of(:era).is_at_most(50) }
    it { should validate_length_of(:historical_commander).is_at_most(100) }
  end

  describe 'associations' do
    it { should have_many(:units).dependent(:destroy) }
    it { should have_many(:battlefield_effects).dependent(:destroy) }
    it { should have_many(:terrains).through(:battlefield_effects) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(army).to be_valid
    end
  end

  describe 'attributes' do
    it 'has all required attributes' do
      expect(army).to respond_to(:name)
      expect(army).to respond_to(:era)
      expect(army).to respond_to(:core_stat)
      expect(army).to respond_to(:unique_weapon)
      expect(army).to respond_to(:signature_ability)
      expect(army).to respond_to(:factual_basis)
      expect(army).to respond_to(:historical_commander)
      expect(army).to respond_to(:description)
    end
  end

  describe 'historical data' do
    it 'can store historical facts' do
      army = create(:army, 
        name: "Roman Legions",
        era: "27 BC - 476 AD",
        factual_basis: "Professional heavy infantry with standardized equipment",
        historical_commander: "Julius Caesar"
      )
      
      expect(army.name).to eq("Roman Legions")
      expect(army.era).to eq("27 BC - 476 AD")
      expect(army.factual_basis.downcase).to include("professional heavy infantry")
      expect(army.historical_commander).to eq("Julius Caesar")
    end
  end

  describe 'units association' do
    it 'can have multiple units' do
      army = create(:army)
      create_list(:unit, 3, army: army)
      
      expect(army.units.count).to eq(3)
      expect(army.units.first).to be_a(Unit)
    end
  end

  describe 'battlefield effects' do
    it 'can have terrain-specific effects' do
      army = create(:army)
      terrain = create(:terrain)
      effect = create(:battlefield_effect, army: army, terrain: terrain)
      
      expect(army.battlefield_effects).to include(effect)
      expect(army.terrains).to include(terrain)
    end
  end
end
