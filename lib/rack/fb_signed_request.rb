require 'base64'
require 'openssl'

# Usage
#
#     use Rack::FBSignedRequest, :secret => 'SECRET'
#
class Rack::FBSignedRequest
  def initialize(app, options)
    @app = app
    @options = options
  end

  def call(env)
    @request = Rack::Request.new(env)
    if @request.POST['signed_request']
      if facebook_params = parse_signed_request(@request.params['signed_request'])
        @request.params['facebook_params'] = facebook_params
        env['rack.request.query_hash'] = @request.params
        env['REQUEST_METHOD'] = 'GET'
      end
    end

    @app.call(env)
  end

  private

  # The following code from omniauth

  def parse_signed_request(value)
    signature, encoded_payload = value.split('.')

    decoded_hex_signature = base64_decode_url(signature)
    decoded_payload = ActiveSupport::JSON.decode(base64_decode_url(encoded_payload))

    unless decoded_payload['algorithm'] == 'HMAC-SHA256'
      raise NotImplementedError, "unkown algorithm: #{decoded_payload['algorithm']}"
    end

    if valid_signature?(@options[:secret], decoded_hex_signature, encoded_payload)
      decoded_payload.with_indifferent_access
    end
  end

  def valid_signature?(secret, signature, payload, algorithm = OpenSSL::Digest::SHA256.new)
    OpenSSL::HMAC.digest(algorithm, secret, payload) == signature
  end

  def base64_decode_url(value)
    value += '=' * (4 - value.size.modulo(4))
    Base64.decode64(value.tr('-_', '+/'))
  end
end
