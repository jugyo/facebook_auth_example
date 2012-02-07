class User < ActiveRecord::Base
  devise :database_authenticatable, :omniauthable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :name,
    :fb_user_id, :fb_access_token, :fb_access_token_expires_at

  def self.find_or_create_from_auth_hash(auth_hash)
    user_data = auth_hash.extra.raw_info
    if user = User.where(:fb_user_id => user_data.id).first
      user
    else
      User.create!(
        :fb_user_id => user_data.id,
        :name => user_data.name,
        :email => user_data.email,
        :fb_access_token => auth_hash.token,
        :fb_access_token_expires_at => auth_hash.expires_at
      )
    end
  end
end
