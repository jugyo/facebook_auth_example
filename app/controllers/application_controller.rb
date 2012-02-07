class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :require_fb_app_installed

  private

  def require_fb_app_installed
    return unless params[:facebook_params]
    if params[:facebook_params][:user_id]
      User.update_access_token(params[:facebook_params])
    else
      @location = user_omniauth_authorize_path(:facebook)
      render 'shared/redirect_from_iframe', :layout => false
    end
  end
end
