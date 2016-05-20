class RemoveEmailAndNamesFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :first_name
    remove_column :users, :last_name

    remove_index :users, :email

    remove_column :users, :email
  end

  def down
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :email, :string

    add_index :users, :email, unique: true
  end
end
