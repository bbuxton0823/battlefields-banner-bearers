ActiveAdmin.register BattlefieldEffect do
  permit_params :terrain_id, :army_id, :heat_penalty, :mobility_penalty, :visibility_penalty, :disease_risk, :morale_modifier, :description

  index do
    selectable_column
    id_column
    column :terrain
    column :army
    column :heat_penalty
    column :mobility_penalty
    column :visibility_penalty
    column :disease_risk
    column :morale_modifier
    actions
  end

  filter :terrain
  filter :army
  filter :heat_penalty
  filter :mobility_penalty

  form do |f|
    f.inputs "Battlefield Effect Details" do
      f.input :terrain
      f.input :army
      f.input :heat_penalty
      f.input :mobility_penalty
      f.input :visibility_penalty
      f.input :disease_risk
      f.input :morale_modifier
      f.input :description
    end
    f.actions
  end
end