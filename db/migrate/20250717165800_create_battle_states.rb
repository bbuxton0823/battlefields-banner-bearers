class CreateBattleStates < ActiveRecord::Migration[7.0]
  def change
    unless table_exists?(:battle_states)
      create_table :battle_states do |t|
        t.references :battle, null: false, foreign_key: true
        t.json :state_data, null: false
        t.timestamps
      end
    end

    unless index_exists?(:battle_states, :battle_id, unique: true)
      add_index :battle_states, :battle_id, unique: true
    end
  end
end