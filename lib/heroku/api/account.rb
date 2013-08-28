require 'heroku/conn'
require 'heroku/model/account'

module Heroku::API::Account
  @@etag = nil

  def account
    @@etag, res = Heroku::Conn::Get('/account', etag: @@etag)
    puts @@etag
    Heroku::Model::Account.new(res.merge("owner" => self))
  end

  def update_account(account)
    Heroku::Conn::Patch("/account", body: account.patchable.to_json)
    account
  end
end
