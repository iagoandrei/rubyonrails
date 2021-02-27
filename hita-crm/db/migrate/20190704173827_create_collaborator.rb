class CreateCollaborator < ActiveRecord::Migration[6.0]
  def change
    create_table :collaborators do |t|
      t.string :name
      t.string :email
      t.string :phone_area
      t.string :phone
      t.string :job_role
      t.string :degree_of_relationship
      t.timestamps
    end

    add_reference :collaborators, :enterprise
  end
end
