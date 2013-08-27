require 'json'
require 'heroku/api'
require 'heroku/conn'
require 'heroku/model/account'

module Heroku::API::Account
  @@etag = nil

  def account
    res    = Heroku::Conn::Get('/account', etag: @@etag)
    @@etag = res["ETag"]
    params = JSON.parse(res.body).merge("owner" => self)

    Heroku::Model::Account.new(params)
  end

  def update_account(account)
    Heroku::Conn::Patch("/account", body: account.patchable.to_json)
    account
  end
end
