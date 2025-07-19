require 'rails_helper'

RSpec.describe Battle, type: :model do
  let(:battle) { create(:battle) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:max_turns) }
    
    it { should validate_length_of(:name).is_at_most(200) }
    it { should validate_inclusion_of(:status).in_array(%w[setup active completed]) }
    it { should validate_numericality_of(:max_turns).is_greater_than(0) }
    it { should validate_numericality_of(:current_turn).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:terrain) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(battle).to be_valid
    end
  end

  describe 'attributes' do
    it 'has all required attributes' do
      expect(battle).to respond_to(:name)
      expect(battle).to respond_to(:status)
      expect(battle).to respond_to(:current_turn)
      expect(battle).to respond_to(:max_turns)
      expect(battle).to respond_to(:victory_conditions)
      expect(battle).to respond_to(:educational_unlocks)
    end
  end

  describe 'default values' do
    it 'defaults status to setup' do
      new_battle = Battle.new
      expect(new_battle.status).to eq('setup')
    end

    it 'defaults current_turn to 0' do
      new_battle = Battle.new
      expect(new_battle.current_turn).to eq(0)
    end
  end

  describe 'status management' do
    it 'can transition through statuses' do
      battle = create(:battle, status: 'setup')
      expect(battle.status).to eq('setup')
      
      battle.update(status: 'active')
      expect(battle.status).to eq('active')
      
      battle.update(status: 'completed')
      expect(battle.status).to eq('completed')
    end

    it 'rejects invalid statuses' do
      battle = build(:battle, status: 'invalid')
      expect(battle).not_to be_valid
      expect(battle.errors[:status]).to include("is not included in the list")
    end
  end

  describe 'turn progression' do
    it 'can increment turns' do
      battle = create(:battle, current_turn: 0, max_turns: 10)
      
      battle.increment!(:current_turn)
      expect(battle.current_turn).to eq(1)
      
      battle.update(current_turn: 5)
      expect(battle.current_turn).to eq(5)
    end

    it 'cannot exceed max turns' do
      battle = create(:battle, current_turn: 9, max_turns: 10)
      
      battle.current_turn = 11
      expect(battle).not_to be_valid
      expect(battle.errors[:current_turn]).to include("must be less than or equal to #{battle.max_turns}")
    end
  end

  describe 'victory conditions' do
    it 'can store victory conditions as text' do
      battle = create(:battle, 
        victory_conditions: "Destroy all enemy units or hold the strategic position for 5 turns"
      )
      
      expect(battle.victory_conditions).to include("Destroy all enemy units")
    end
  end

  describe 'educational unlocks' do
    it 'can store educational content' do
      battle = create(:battle, 
        educational_unlocks: "Unlocked: Understanding of phalanx formation tactics"
      )
      
      expect(battle.educational_unlocks).to include("phalanx formation tactics")
    end
  end

  describe 'terrain association' do
    it 'belongs to a terrain' do
      terrain = create(:terrain)
      battle = create(:battle, terrain: terrain)
      
      expect(battle.terrain).to eq(terrain)
      expect(terrain.battles).to include(battle)
    end

    it 'requires a terrain' do
      battle = build(:battle, terrain: nil)
      expect(battle).not_to be_valid
      expect(battle.errors[:terrain]).to include("must exist")
    end
  end

  describe 'battle lifecycle' do
    it 'can simulate a complete battle' do
      battle = create(:battle, current_turn: 0, max_turns: 5)
      
      # Start battle
      battle.update(status: 'active')
      expect(battle.status).to eq('active')
      
      # Progress through turns
      3.times { battle.increment!(:current_turn) }
      expect(battle.current_turn).to eq(3)
      
      # Complete battle
      battle.update(status: 'completed')
      expect(battle.status).to eq('completed')
    end
  end
end
