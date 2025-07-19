class AddColdStressToTerrains < ActiveRecord::Migration[8.0]
  def change
    add_column :terrains, :cold_stress, :integer
  end
end
