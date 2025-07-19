# frozen_string_literal: true

# Mock implementation of the BattleState model for testing
# This avoids the need for the actual database table to exist in test environments
class BattleStateMock
  class << self
    # In-memory storage for battle states
    def storage
      @storage ||= []
    end

    # Clear all stored battle states
    def clear
      @storage = []
    end

    # Find a battle state by ID
    def find(id)
      storage.find { |state| state.id == id }
    end

    # Get the last created battle state
    def last
      storage.last
    end

    # Create a new battle state
    def create!(attributes)
      new_state = new(attributes)
      storage << new_state
      new_state
    end

    # Find or create by battle_id
    def find_or_create_by(attributes)
      existing = storage.find { |state| state.battle_id == attributes[:battle_id] }
      return existing if existing

      create!(attributes)
    end

    # Check if table exists (always returns true for mock)
    def table_exists?
      true
    end
  end

  attr_accessor :id, :battle_id, :state_data, :created_at, :updated_at, :battle

  def initialize(attributes = {})
    @id = attributes[:id] || storage.length + 1
    @battle_id = attributes[:battle_id]
    @battle = attributes[:battle]
    @state_data = attributes[:state_data]
    @created_at = attributes[:created_at] || Time.current
    @updated_at = attributes[:updated_at] || Time.current
  end

  def save!
    self.class.storage << self unless self.class.storage.include?(self)
    true
  end

  def update!(attributes)
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=")
    end
    self.updated_at = Time.current
    true
  end

  def persisted?
    self.class.storage.include?(self)
  end

  private

  def storage
    self.class.storage
  end
end

# Replace the actual BattleState with our mock in test environment
if Rails.env.test?
  silence_warnings do
    BattleState = BattleStateMock unless defined?(BattleState)
  end
end
