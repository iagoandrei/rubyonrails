class AddLatitudeLongitudeToEnterprise < ActiveRecord::Migration[6.0]
  def change
    add_column :enterprises, :latitude, :string
    add_column :enterprises, :longitude, :string
  end
end
