module Heroku
  class API
    module App
      @@etags       = {}
      RESOURCE_TYPE = "APP"

      def app(name_or_id)
        etag, res =
          Heroku::Conn::Get(
            "/apps/#{name_or_id}",
            etag: @@etags[name_or_id],
            r_type: RESOURCE_TYPE
          )

        @@etags[res['id']]   = etag
        @@etags[res['name']] = etag
        Heroku::Model::App.new(res.merge("parent" => self))
      end

      def new(params = {})
        _, res =
          Heroku::Conn::Post(
            '/apps',
            r_type: RESOURCE_TYPE,
            body: params.to_json
          )

        Heroku::Model::App.new(res.merge("parent" => self))
      end

      def update_app(app)
        etag, res =
          Heroku::Conn::Patch(
            app.end_point,
            etag: @@etags[app.id] || @@etags[app.name],
            r_type: RESOURCE_TYPE,
            body: app.patchable.to_json
          )

        @@etags[res['id']]   = etag
        @@etags[res['name']] = etag
        Heroku::Model::App.new(res.merge("parent" => self))
      end

      def delete_app(app)
        Heroku::Conn::Delete(app.end_point)
        true
      end
    end
  end
end
