require 'net/http'
require 'uri'

class JsonWebToken
  def self.verify(token)
    JWT.decode(token, nil,
               true,
               algorithms: 'RS256',
               iss: "https://#{ENV['AUTH0_DOMAIN']}/",
               verify_iss: true,
               aud: Rails.application.secrets.auth0_api_audience,
               verify_aud: true) do |header|
      jwks_hash[header['kid']]
    end
  end

  def self.jwks_hash
    jwks_raw = Net::HTTP.get(URI("https://#{ENV['AUTH0_DOMAIN']}/.well-known/jwks.json"))
    jwks_keys = Array(JSON.parse(jwks_raw)['keys'])
    Hash[
      jwks_keys
      .map do |k|
        [
          k['kid'],
          OpenSSL::X509::Certificate.new(
            Base64.decode64(k['x5c'].first)
          ).public_key
        ]
      end
    ]
  end
end
