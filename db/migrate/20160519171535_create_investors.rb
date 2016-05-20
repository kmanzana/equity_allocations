class CreateInvestors < ActiveRecord::Migration
  def change
    create_table :investors do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :tax_id
      t.boolean :verified
      t.integer :investor_id
      t.string :investor_key
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :organization_name
      t.datetime :birth_date
      t.boolean :foreign_address
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.boolean :person
      t.string :email

      t.timestamps null: false
    end

    add_index :investors, :tax_id, unique: true
    add_index :investors, :investor_id, unique: true
    add_index :investors, :investor_key, unique: true
  end
end
