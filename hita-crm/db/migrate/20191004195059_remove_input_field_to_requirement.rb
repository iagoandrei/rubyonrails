class RemoveInputFieldToRequirement < ActiveRecord::Migration[6.0]
  def change
    remove_column :requirements, :input
  end
end
