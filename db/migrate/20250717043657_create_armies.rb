class CreateArmies < ActiveRecord::Migration[8.0]
  def change
    create_table :armies do |t|
      t.string :name
      t.string :era
      t.string :core_stat
      t.string :unique_weapon
      t.string :signature_ability
      t.text :factual_basis
      t.string :historical_commander
      t.text :description

      t.timestamps
    end
  end
end
