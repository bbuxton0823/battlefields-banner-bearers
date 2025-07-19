class CreateUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :units do |t|
      t.references :army, null: false, foreign_key: true
      t.string :name
      t.string :unit_type
      t.integer :attack
      t.integer :defense
      t.integer :health
      t.integer :morale
      t.integer :movement
      t.string :special_ability
      t.text :description

      t.timestamps
    end
  end
end
