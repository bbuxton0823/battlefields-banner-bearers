class CreateTerrains < ActiveRecord::Migration[8.0]
  def change
    create_table :terrains do |t|
      t.string :name
      t.string :terrain_type
      t.string :climate
      t.integer :mobility_modifier
      t.integer :heat_stress
      t.integer :disease_risk
      t.integer :visibility
      t.text :description
      t.text :historical_significance

      t.timestamps
    end
  end
end
