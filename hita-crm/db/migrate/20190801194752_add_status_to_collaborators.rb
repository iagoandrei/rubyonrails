class AddStatusToCollaborators < ActiveRecord::Migration[6.0]
  def change
    add_column :collaborators, :status, :integer
  end
end
