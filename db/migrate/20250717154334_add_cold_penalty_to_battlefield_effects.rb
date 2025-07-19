class AddColdPenaltyToBattlefieldEffects < ActiveRecord::Migration[8.0]
  def change
    add_column :battlefield_effects, :cold_penalty, :integer
  end
end
