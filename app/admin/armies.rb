ActiveAdmin.register Army do
  permit_params :name, :era, :core_stat, :unique_weapon, :signature_ability, :factual_basis, :historical_commander, :description

  index do
    selectable_column
    id_column
    column :name
    column :era
    column :core_stat
    column :historical_commander
    actions
  end

  filter :name
  filter :era
  filter :core_stat
  filter :historical_commander

  form do |f|
    f.inputs "Army Details" do
      f.input :name
      f.input :era
      f.input :core_stat
      f.input :unique_weapon
      f.input :signature_ability
      f.input :factual_basis
      f.input :historical_commander
      f.input :description
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :era
      row :core_stat
      row :unique_weapon
      row :signature_ability
      row :factual_basis
      row :historical_commander
      row :description
    end

    panel "Units" do
      table_for army.units do
        column :name
        column :unit_type
        column :attack
        column :defense
        column :health
        column :morale
        column :movement
      end
    end
  end
end