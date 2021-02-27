class CreateEnterprise < ActiveRecord::Migration[6.0]
  def change
    create_table :enterprises do |t|
      t.string :name
      t.string :industy_sector
      t.string :enterprise_type
      t.string :cep
      t.string :city
      t.string :state
      t.string :address
      t.string :business_name
      t.string :cnpj
      t.timestamps
    end
  end
end
