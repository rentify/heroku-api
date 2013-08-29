require 'heroku/conn'

module Heroku
  class API
    module Regions
      def regions
        Heroku::Conn::Get("/regions").last
      end
    end
  end
end
