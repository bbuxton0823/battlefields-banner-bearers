class CreateBattleUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :battle_units do |t|
      t.references :battle, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true
      t.references :army, null: false, foreign_key: true
      
      t.integer :health, null: false, default: 100
      t.integer :morale, null: false, default: 100
      t.integer :position_x, null: false, default: 0
      t.integer :position_y, null: false, default: 0
      
      # Temporary bonuses for special abilities
      t.integer :temp_attack_bonus, default: 0
      t.integer :temp_defense_bonus, default: 0
      t.integer :temp_morale_bonus, default: 0
      t.integer :temp_movement_bonus, default: 0
      
      # Cooldown tracking
      t.datetime :last_ability_use
      
      t.timestamps
    end
    
    add_index :battle_units, [:battle_id, :army_id]
    add_index :battle_units, [:battle_id, :unit_id]
    add_index :battle_units, [:battle_id, :position_x, :position_y]
  end
end