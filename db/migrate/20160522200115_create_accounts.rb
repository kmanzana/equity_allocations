class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.boolean :savings_account, default: false
      t.integer :routing_number
      t.integer :account_number
      t.references :investor, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
