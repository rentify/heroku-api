require 'base64'
require 'heroku/version'

class Heroku::Config
  USER_AGENT = "Heroku Platform API Gem #{Heroku::VERSION}"

  def self.auth_token
    @@auth_token
  end

  def self.auth_token_update(api_key)
    raise ArgumentError, "Need an API key" if api_key.nil?

    @@auth_token = Base64.strict_encode64(":#{api_key}\n").strip
  end

  module ConfigMethods
    def configure(opts = {})
      Heroku::Config.auth_token_update(opts[:api_key])
    end
  end
end
