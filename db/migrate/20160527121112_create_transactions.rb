class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :account, index: true, foreign_key: true
      t.references :investment, index: true, foreign_key: true
      t.integer    :crowd_pay_id
      t.string     :command
      t.integer    :amount
      t.datetime   :date

      t.timestamps null: false
    end
  end
end
