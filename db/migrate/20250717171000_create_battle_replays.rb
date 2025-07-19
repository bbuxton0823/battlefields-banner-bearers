class CreateBattleReplays < ActiveRecord::Migration[7.0]
  def change
    create_table :battle_replays do |t|
      t.references :battle, null: false, foreign_key: true
      t.references :unit, null: true, foreign_key: { to_table: :battle_units }
      t.references :target, null: true, foreign_key: { to_table: :battle_units }
      
      t.integer :turn_number, null: false
      t.string :action_type, null: false
      t.jsonb :details, default: {}
      t.datetime :timestamp
      
      t.timestamps
    end

    add_index :battle_replays, [:battle_id, :turn_number]
    add_index :battle_replays, [:battle_id, :created_at]
  end
end