class AddWordPressAttributesToUsers < ActiveRecord::Migration
  def up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :username, :string
    add_column :users, :word_press_id, :integer

    add_index :users, :username, unique: true

    remove_column :users, :name
  end

  def down
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :username
    remove_column :users, :word_press_id, :integer

    remove_index :users, :username, unique: true

    add_column :users, :name, :string
  end
end
