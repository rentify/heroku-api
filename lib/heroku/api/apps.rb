require 'heroku/model'

module Heroku::API::Apps
  @@etag        = nil
  RESOURCE_TYPE = "APPS"

  def apps
    Heroku::Model::AppList.new( ->(parent){
      @@etag, res =
        Heroku::Conn::Get(
          "/apps",
          etag: @@etag,
          r_type: RESOURCE_TYPE
        )

      res.map do |params|
        Heroku::Model::App.new(params.merge("parent" => parent))
      end
    })
  end

end
