class CreateInvestments < ActiveRecord::Migration
  def change
    create_table :investments do |t|
      t.references :account, index: true, foreign_key: true
      t.integer :amount
      t.integer :number_of_shares

      t.timestamps null: false
    end
  end
end
