class CreateBattlefieldEffects < ActiveRecord::Migration[8.0]
  def change
    create_table :battlefield_effects do |t|
      t.references :terrain, null: false, foreign_key: true
      t.references :army, null: false, foreign_key: true
      t.integer :heat_penalty
      t.integer :mobility_penalty
      t.integer :visibility_penalty
      t.integer :disease_risk
      t.integer :morale_modifier
      t.text :description

      t.timestamps
    end
  end
end
