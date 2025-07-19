class BattleState < ApplicationRecord
  belongs_to :battle
  
  validates :state_data, presence: true
  validates :battle_id, uniqueness: true
  
  def state_hash
    JSON.parse(state_data, symbolize_names: true)
  rescue JSON::ParserError
    {}
  end
  
  def state_hash=(hash)
    self.state_data = hash.to_json
  end
end