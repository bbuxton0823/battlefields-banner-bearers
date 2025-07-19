class AddWinnerIdToBattles < ActiveRecord::Migration[8.0]
  def change
    add_column :battles, :winner_id, :integer
  end
end
