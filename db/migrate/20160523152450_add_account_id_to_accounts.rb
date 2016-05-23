class AddAccountIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :account_id, :integer
  end
end
