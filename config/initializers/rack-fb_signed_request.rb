require 'rack/fb_signed_request'
FacebookAuthExample::Application.config.middleware.use Rack::FBSignedRequest, :secret => FACEBOOK_CONFIG[:secret]
