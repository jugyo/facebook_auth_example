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
        :email => user_data.email
      )
    end
  end

  def self.update_access_token(facebook_params)
    if user = User.where(:fb_user_id => facebook_params[:user_id]).first
      result = HTTPClient.new.get_content 'https://graph.facebook.com/oauth/access_token',
        :client_id         => FACEBOOK_CONFIG[:app_id],
        :client_secret     => FACEBOOK_CONFIG[:secret],
        :grant_type        => 'fb_exchange_token',
        :fb_exchange_token => facebook_params[:oauth_token]
      if result =~ /^access_token=(.*)&expires=(.*)$/
        user.update_attributes!(
          :fb_access_token => $1,
          :fb_access_token_expires_at => Time.at(Time.now.to_i + $2.to_i)
        )
      end
    else
      raise "User not found. id => #{facebook_params[:user_id]}"
    end
  end
end
