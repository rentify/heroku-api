require 'heroku/api/app'
require 'heroku/model/array_proxy'

module Heroku
  module Model
    class AppList < Heroku::Model::ArrayProxy
      include Heroku::API::App

      def inspect
        "#<Heroku::Model::Apps>"
      end

      def [](key)
        case key
        when String, Symbol then app(key.to_s)
        else                     super(key)
        end
      end
    end
  end
end
