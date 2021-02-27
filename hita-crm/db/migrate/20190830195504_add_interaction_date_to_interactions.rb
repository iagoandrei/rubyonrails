class AddInteractionDateToInteractions < ActiveRecord::Migration[6.0]
  def change
    add_column :interactions, :interaction_date, :datetime
  end
end
