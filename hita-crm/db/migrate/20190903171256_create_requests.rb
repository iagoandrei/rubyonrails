class CreateRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :requests do |t|
      t.integer :step
      t.timestamps
    end

    add_reference :requests, :enterprise
    add_reference :requests, :user
  end
end
