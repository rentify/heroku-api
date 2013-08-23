require 'base64'

class Heroku::Config
  def self.auth_token
    @@auth_token
  end

  def self.auth_token_update(email, api_key)
    raise ArgumentError, "Need an email"   if email.nil?
    raise ArgumentError, "Need an API key" if api_key.nil?

    @@auth_token = Base64.encode64("#{email}:#{api_key}").strip
  end

  module ConfigMethods
    def configure(opts = {})
      Heroku::Config.auth_token_update(
        opts[:email],
        opts[:api_key]
      )
    end
  end
end
