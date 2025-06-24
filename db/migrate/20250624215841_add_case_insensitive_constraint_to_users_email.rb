class AddCaseInsensitiveConstraintToUsersEmail < ActiveRecord::Migration[8.0]
  def up
    # Remove the original case-sensitive index if it exists
    remove_index :users, name: 'index_users_on_email_address' if index_exists?(:users, :email_address, name: 'index_users_on_email_address')

    # Convert all existing emails to lowercase
    execute 'UPDATE users SET email_address = LOWER(email_address) WHERE email_address != LOWER(email_address)'

    # Add a unique index that enforces case-insensitive comparison
    add_index :users, 'LOWER(email_address)', unique: true, name: 'index_users_on_lower_email_address'
  end

  def down
    # Remove the case-insensitive index
    remove_index :users, name: 'index_users_on_lower_email_address'

    # Re-add the original case-sensitive index
    add_index :users, :email_address, unique: true, name: 'index_users_on_email_address'
  end
end
