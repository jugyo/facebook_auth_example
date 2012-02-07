class AddFbColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :fb_user_id, :integer
    add_column :users, :fb_access_token, :string
    add_column :users, :fb_access_token_expires_at, :datetime
  end
end
