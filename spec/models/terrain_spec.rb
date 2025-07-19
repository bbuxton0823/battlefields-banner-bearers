require 'rails_helper'

RSpec.describe Terrain, type: :model do
  let(:terrain) { create(:terrain) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:terrain_type) }
    it { should validate_presence_of(:climate) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:historical_significance) }
    
    it { should validate_numericality_of(:mobility_modifier).is_greater_than_or_equal_to(-10) }
    it { should validate_numericality_of(:heat_stress).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:disease_risk).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:visibility).is_greater_than_or_equal_to(0) }
    
    it { should validate_length_of(:name).is_at_most(100) }
    it { should validate_length_of(:terrain_type).is_at_most(50) }
    it { should validate_length_of(:climate).is_at_most(50) }
  end

  describe 'associations' do
    it { should have_many(:battlefield_effects).dependent(:destroy) }
    it { should have_many(:armies).through(:battlefield_effects) }
    it { should have_many(:battles).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(terrain).to be_valid
    end
  end

  describe 'attributes' do
    it 'has all required attributes' do
      expect(terrain).to respond_to(:name)
      expect(terrain).to respond_to(:terrain_type)
      expect(terrain).to respond_to(:climate)
      expect(terrain).to respond_to(:mobility_modifier)
      expect(terrain).to respond_to(:heat_stress)
      expect(terrain).to respond_to(:disease_risk)
      expect(terrain).to respond_to(:visibility)
      expect(terrain).to respond_to(:description)
      expect(terrain).to respond_to(:historical_significance)
    end
  end

  describe 'terrain types' do
    it 'supports different terrain types' do
      desert = create(:terrain, terrain_type: "Desert", name: "Mojave Desert")
      mountain = create(:terrain, terrain_type: "Mountain", name: "Tibetan Mountains")
      forest = create(:terrain, terrain_type: "Forest", name: "Black Forest")
      
      expect(desert.terrain_type).to eq("Desert")
      expect(mountain.terrain_type).to eq("Mountain")
      expect(forest.terrain_type).to eq("Forest")
    end
  end

  describe 'environmental modifiers' do
    it 'has environmental impact values' do
      terrain = create(:terrain, 
        mobility_modifier: -3,
        heat_stress: 8,
        disease_risk: 2,
        visibility: 6
      )
      
      expect(terrain.mobility_modifier).to eq(-3)
      expect(terrain.heat_stress).to eq(8)
      expect(terrain.disease_risk).to eq(2)
      expect(terrain.visibility).to eq(6)
    end

    it 'rejects extreme negative values' do
      terrain = build(:terrain, mobility_modifier: -15)
      expect(terrain).not_to be_valid
    end
  end

  describe 'historical significance' do
    it 'stores historical context' do
      terrain = create(:terrain, 
        name: "Thermopylae Pass",
        historical_significance: "Site of the famous 300 Spartans' last stand against Persian invasion in 480 BC"
      )
      
      expect(terrain.historical_significance).to include("300 Spartans")
      expect(terrain.historical_significance).to include("480 BC")
    end
  end

  describe 'battlefield effects' do
    it 'can have effects on armies' do
      terrain = create(:terrain)
      army = create(:army)
      effect = create(:battlefield_effect, terrain: terrain, army: army)
      
      expect(terrain.battlefield_effects).to include(effect)
      expect(terrain.armies).to include(army)
    end
  end

  describe 'battles' do
    it 'can host multiple battles' do
      terrain = create(:terrain)
      create_list(:battle, 3, terrain: terrain)
      
      expect(terrain.battles.count).to eq(3)
      expect(terrain.battles.first).to be_a(Battle)
    end
  end
end
