require 'rails_helper'

RSpec.describe EducationalContentService do
  let(:terrain) { create(:terrain, name: "Mojave Desert", terrain_type: "Desert", climate: "Hot and Arid") }
  let(:army) { create(:army, name: "Roman Legions", era: "27 BC - 476 AD") }

  describe '.generate_contextual_content' do
    it 'returns a hash with educational content' do
      content = EducationalContentService.generate_contextual_content(terrain, army)
      
      expect(content).to be_a(Hash)
      expect(content).to have_key(:title)
      expect(content).to have_key(:content)
      expect(content).to have_key(:historical_fact)
      expect(content).to have_key(:learning_objective)
    end

    it 'includes terrain-specific information' do
      content = EducationalContentService.generate_contextual_content(terrain, army)
      
      expect(content[:content]).to include(terrain.name)
      expect(content[:content]).to include(terrain.terrain_type)
      expect(content[:content]).to include(terrain.climate)
    end

    it 'includes army-specific information' do
      content = EducationalContentService.generate_contextual_content(terrain, army)
      
      expect(content[:content]).to include(army.name)
      expect(content[:content]).to include(army.era)
    end

    it 'includes learning objectives' do
      content = EducationalContentService.generate_contextual_content(terrain, army)
      
      expect(content[:learning_objective]).to be_present
      expect(content[:learning_objective]).to be_a(String)
    end

    it 'includes historical facts' do
      content = EducationalContentService.generate_contextual_content(terrain, army)
      
      expect(content[:historical_fact]).to be_present
      expect(content[:historical_fact]).to be_a(String)
    end

    it 'generates different content for different terrain-army combinations' do
      terrain2 = create(:terrain, name: "Tibetan Mountains", terrain_type: "Mountain", climate: "Cold and High Altitude")
      army2 = create(:army, name: "Mongol Cavalry", era: "1206-1368 AD")
      
      content1 = EducationalContentService.generate_contextual_content(terrain, army)
      content2 = EducationalContentService.generate_contextual_content(terrain2, army2)
      
      expect(content1[:content]).not_to eq(content2[:content])
    end
  end

  describe '.generate_battle_summary' do
    let(:battle) { create(:battle, terrain: terrain) }
    let(:army2) { create(:army, name: "Greek Hoplites", era: "800-146 BC") }
    
    before do
      # Create units for both armies to associate them with the battle
      unit1 = create(:unit, army: army)
      unit2 = create(:unit, army: army2)
      
      # Associate units with battle through battle_units
      create(:battle_unit, battle: battle, unit: unit1)
      create(:battle_unit, battle: battle, unit: unit2)
    end

    it 'returns a hash with battle summary' do
      summary = EducationalContentService.generate_battle_summary(battle)
      
      expect(summary).to be_a(Hash)
      expect(summary).to have_key(:title)
      expect(summary).to have_key(:summary)
      expect(summary).to have_key(:key_learning)
    end

    it 'includes battle participants' do
      summary = EducationalContentService.generate_battle_summary(battle)
      
      expect(summary[:summary]).to include(army.name)
      expect(summary[:summary]).to include(army2.name)
    end

    it 'includes terrain context' do
      summary = EducationalContentService.generate_battle_summary(battle)
      
      expect(summary[:summary]).to include(terrain.name)
    end
  end

  describe '.get_unlockable_content' do
    it 'returns unlockable content for given criteria' do
      content = EducationalContentService.get_unlockable_content("first_victory")
      
      expect(content).to be_a(Hash)
      expect(content).to have_key(:title)
      expect(content).to have_key(:description)
      expect(content).to have_key(:historical_context)
    end

    it 'returns nil for unknown criteria' do
      content = EducationalContentService.get_unlockable_content("unknown_criteria")
      
      expect(content).to be_nil
    end
  end
end