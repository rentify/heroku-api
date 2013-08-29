require 'heroku/conn'

module Heroku::API::Regions
  def regions
    Heroku::Conn::Get("/regions").last
  end
end
