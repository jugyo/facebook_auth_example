class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_or_create_from_auth_hash(request.env["omniauth.auth"])
    sign_in @user

    location = "http://apps.facebook.com/#{FACEBOOK_CONFIG[:app_namespace]}" + (stored_location_for(:user) || root_path)
    redirect_to location
  end
end
