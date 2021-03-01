class AddCnpjToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :cnpj, :string
  end
end
