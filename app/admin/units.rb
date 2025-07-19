ActiveAdmin.register Unit do
  permit_params :army_id, :name, :unit_type, :attack, :defense, :health, :morale, :movement, :special_ability, :description

  index do
    selectable_column
    id_column
    column :name
    column :army
    column :unit_type
    column :attack
    column :defense
    column :health
    column :morale
    actions
  end

  filter :name
  filter :army
  filter :unit_type
  filter :attack
  filter :defense

  form do |f|
    f.inputs "Unit Details" do
      f.input :army
      f.input :name
      f.input :unit_type, as: :select, collection: ['commander', 'infantry', 'cavalry', 'ranged', 'siege']
      f.input :attack
      f.input :defense
      f.input :health
      f.input :morale
      f.input :movement
      f.input :special_ability
      f.input :description
    end
    f.actions
  end
end