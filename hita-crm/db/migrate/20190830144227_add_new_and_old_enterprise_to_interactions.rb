class AddNewAndOldEnterpriseToInteractions < ActiveRecord::Migration[6.0]
  def change
    add_column :interactions, :enterprise_changed_old, :bigint
    add_column :interactions, :enterprise_changed_new, :bigint
  end
end
