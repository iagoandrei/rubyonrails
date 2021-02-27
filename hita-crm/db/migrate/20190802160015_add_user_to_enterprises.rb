class AddUserToEnterprises < ActiveRecord::Migration[6.0]
  def change
    add_reference :enterprises, :user, null: true, foreign_key: true, index: true
  end
end
