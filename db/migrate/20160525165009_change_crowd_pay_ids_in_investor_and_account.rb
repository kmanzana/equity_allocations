class ChangeCrowdPayIdsInInvestorAndAccount < ActiveRecord::Migration
  def change
    rename_column :investors, :investor_id, :crowd_pay_id
    rename_column :investors, :investor_key, :crowd_pay_key
    rename_column :accounts, :account_id, :crowd_pay_id
  end
end
