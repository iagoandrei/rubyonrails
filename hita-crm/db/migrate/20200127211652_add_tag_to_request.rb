class AddTagToRequest < ActiveRecord::Migration[6.0]
  def change
  	add_column :requests, :tag, :text, default: ''
  end
end
