class AddSpecialAbilitiesToUnits < ActiveRecord::Migration[8.0]
  def change
    add_column :units, :special_abilities, :text
  end
end
