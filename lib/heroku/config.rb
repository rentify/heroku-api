require 'base64'
require 'heroku/version'

class Heroku::Config
  USER_AGENT = "Heroku Platform API Gem #{Heroku::VERSION}"

  def self.auth_token
    @@auth_token
  end

  def self.api_key=(key)
    raise ArgumentError, "Need an API key" if key.nil?
    @@auth_token = Base64.strict_encode64(":#{key}\n").strip
    key
  end

  module ConfigMethods
    def configure # yield
      yield Heroku::Config
    end
  end
end
