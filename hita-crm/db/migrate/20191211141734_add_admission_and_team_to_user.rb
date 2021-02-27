class AddAdmissionAndTeamToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :admission, :date
    add_column :users, :team, :string
  end
end
