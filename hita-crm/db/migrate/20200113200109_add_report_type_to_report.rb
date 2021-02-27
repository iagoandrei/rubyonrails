class AddReportTypeToReport < ActiveRecord::Migration[6.0]
  def change
    add_column :reports, :report_type, :string
  end
end
