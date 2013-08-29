module Heroku::API::App
  @@etags = {}

  # TODO: Utilise etag caching after removing method from key in conn.rb
  def app(name_or_id)
    etag, res          = Heroku::Conn::Get("/apps/#{name_or_id}")
    @@etags[res['id']] = etag
    Heroku::Model::App.new(res.merge("parent" => self))
  end

  def new(params = {})
    etag, res          = Heroku::Conn::Post('/apps', body: params.to_json)
    @@etags[res['id']] = etag
    Heroku::Model::App.new(res.merge("parent" => self))
  end

  # TODO: Cache here also.
  def update_app(app)
    etag, res = Heroku::Conn::Patch(app.end_point, body: app.patchable.to_json)
    @@etags[res['id']] = etag
    Heroku::Model::App.new(res.merge("parent" => self))
  end

  def delete_app(app)
    Heroku::Conn::Delete(app.end_point)
    true
  end
end
