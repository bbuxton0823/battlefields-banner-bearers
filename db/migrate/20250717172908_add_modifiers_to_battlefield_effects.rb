class AddModifiersToBattlefieldEffects < ActiveRecord::Migration[8.0]
  def change
    add_column :battlefield_effects, :attack_modifier, :integer unless column_exists?(:battlefield_effects, :attack_modifier)
    add_column :battlefield_effects, :defense_modifier, :integer unless column_exists?(:battlefield_effects, :defense_modifier)
    add_column :battlefield_effects, :morale_modifier, :integer unless column_exists?(:battlefield_effects, :morale_modifier)
  end
end
