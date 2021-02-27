class AddAreaToCollaborator < ActiveRecord::Migration[6.0]
  def change
    add_column :collaborators, :area, :string
  end
end
