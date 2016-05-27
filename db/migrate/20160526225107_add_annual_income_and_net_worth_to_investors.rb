class AddAnnualIncomeAndNetWorthToInvestors < ActiveRecord::Migration
  def change
    add_column :investors, :annual_income, :integer
    add_column :investors, :net_worth, :integer
  end
end
