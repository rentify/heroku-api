require 'json'
require 'heroku/model/account'

module Heroku::API::Account
  def account(owner = default_owner)
    res    = Heroku::API::Conn::Get('/account', etag: @@etag)
    @@etag = res["ETag"]

    Heroku::Model::Account.new(JSON.parse(res.body))
  end
end
