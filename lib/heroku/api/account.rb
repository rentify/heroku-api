require 'heroku/conn'
require 'heroku/model/account'

module Heroku
  class API
    module Account
      @@etag        = nil
      RESOURCE_TYPE = "ACCOUNT"

      def account
        @@etag, res =
          Heroku::Conn::Get(
            '/account',
            etag: @@etag,
            r_type: RESOURCE_TYPE
          )

        Heroku::Model::Account.new(res.merge("parent" => self))
      end

      def update_account(account)
        @@etag, res =
          Heroku::Conn::Patch(
            "/account",
            r_type: RESOURCE_TYPE,
            body: account.patchable.to_json
          )

        Heroku::Model::Account.new(res.merge("parent" => self))
      end
    end
  end
end
