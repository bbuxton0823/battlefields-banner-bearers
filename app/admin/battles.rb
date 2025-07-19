ActiveAdmin.register Battle do
  permit_params :name, :terrain_id, :current_turn, :max_turns, :status, :victory_condition, :educational_summary

  index do
    selectable_column
    id_column
    column :name
    column :terrain
    column :current_turn
    column :max_turns
    column :status
    actions
  end

  filter :name
  filter :terrain
  filter :status

  form do |f|
    f.inputs "Battle Details" do
      f.input :name
      f.input :terrain
      f.input :current_turn
      f.input :max_turns
      f.input :status, as: :select, collection: ['pending', 'active', 'completed', 'draw']
      f.input :victory_condition
      f.input :educational_summary
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :terrain
      row :current_turn
      row :max_turns
      row :status
      row :victory_condition
      row :educational_summary
    end
  end
end