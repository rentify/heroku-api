require 'base64'
require 'heroku/version'

module Heroku
  class Properties
    require 'heroku/properties/null_logger'

    USER_AGENT   = "Heroku Platform API Gem #{Heroku::VERSION}"
    @@auth_token = nil
    @@logger     = nil

    def self.auth_token
      @@auth_token
    end

    def self.api_key=(key)
      raise ArgumentError, "Need an API key" if key.nil?
      @@auth_token = Base64.strict_encode64(":#{key}\n").strip
      key
    end

    def self.logger
      @@logger || NullLogger.new
    end

    def self.logger=(logger)
      @@logger = logger
    end

    module ConfigMethods
      def configure # yield
        yield Heroku::Properties
      end
    end
  end
end
