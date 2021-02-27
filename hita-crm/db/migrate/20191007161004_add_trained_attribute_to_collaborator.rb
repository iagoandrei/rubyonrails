class AddTrainedAttributeToCollaborator < ActiveRecord::Migration[6.0]
  def change
    add_column :collaborators, :trained, :string
  end
end
