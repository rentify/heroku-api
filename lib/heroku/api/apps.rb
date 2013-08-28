require 'heroku/model'

module Heroku::API::Apps
  @@etag = nil

  def apps
    Heroku::Model::AppList.new( ->(parent){
      @@etag, res = Heroku::Conn::Get("/apps", etag: @@etag)

      res.map do |params|
        Heroku::Model::App.new(params.merge("parent" => parent))
      end
    })
  end

end
