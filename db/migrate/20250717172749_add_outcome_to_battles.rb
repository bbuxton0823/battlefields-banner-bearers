class AddOutcomeToBattles < ActiveRecord::Migration[8.0]
  def change
    add_column :battles, :outcome, :string
  end
end
