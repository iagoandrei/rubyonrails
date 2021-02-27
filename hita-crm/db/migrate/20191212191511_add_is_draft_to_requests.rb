class AddIsDraftToRequests < ActiveRecord::Migration[6.0]
  def change
  	add_column :requests, :is_draft, :boolean, default: false
  end
end
