class AddAccountNameToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :account_name, :string
  end
end
