class AddUserToReports < ActiveRecord::Migration[6.0]
  def change
    add_reference :reports, :user, null: true
  end
end
