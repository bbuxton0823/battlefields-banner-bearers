ActiveAdmin.register Terrain do
  permit_params :name, :terrain_type, :climate, :mobility_modifier, :heat_stress, :disease_risk, :visibility, :description, :historical_significance

  index do
    selectable_column
    id_column
    column :name
    column :terrain_type
    column :climate
    column :mobility_modifier
    column :heat_stress
    actions
  end

  filter :name
  filter :terrain_type
  filter :climate

  form do |f|
    f.inputs "Terrain Details" do
      f.input :name
      f.input :terrain_type, as: :select, collection: ['desert', 'mountain', 'forest', 'tundra', 'coastal']
      f.input :climate
      f.input :mobility_modifier
      f.input :heat_stress
      f.input :disease_risk
      f.input :visibility
      f.input :description
      f.input :historical_significance
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :terrain_type
      row :climate
      row :mobility_modifier
      row :heat_stress
      row :disease_risk
      row :visibility
      row :description
      row :historical_significance
    end

    panel "Battlefield Effects" do
      table_for terrain.battlefield_effects do
        column :army
        column :heat_penalty
        column :mobility_penalty
        column :visibility_penalty
        column :morale_modifier
      end
    end
  end
end