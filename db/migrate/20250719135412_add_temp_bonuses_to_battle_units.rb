class AddTempBonusesToBattleUnits < ActiveRecord::Migration[8.0]
  def change
    %i[
      temp_attack_bonus
      temp_defense_bonus
      temp_morale_bonus
      temp_movement_bonus
    ].each do |column|
      unless column_exists?(:battle_units, column)
        add_column :battle_units, column, :integer, default: 0
      end
    end
  end
end
