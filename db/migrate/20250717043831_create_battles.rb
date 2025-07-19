class CreateBattles < ActiveRecord::Migration[8.0]
  def change
    create_table :battles do |t|
      t.string :name
      t.references :terrain, null: false, foreign_key: true
      t.string :status
      t.integer :current_turn
      t.integer :max_turns
      t.text :victory_conditions
      t.text :educational_unlocks

      t.timestamps
    end
  end
end
