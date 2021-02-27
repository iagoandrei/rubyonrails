class RenameEnterpriseIndustySector < ActiveRecord::Migration[6.0]
  def change
  	rename_column :enterprises, :industy_sector, :industry_sector
  end
end
