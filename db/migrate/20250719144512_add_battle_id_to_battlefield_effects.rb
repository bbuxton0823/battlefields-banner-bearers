class AddBattleIdToBattlefieldEffects < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:battlefield_effects, :battle_id)
      add_reference :battlefield_effects, :battle, foreign_key: true, index: true
    end
  end
end
