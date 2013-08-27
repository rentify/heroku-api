require 'heroku/conn'

module Heroku::API::Password
  def update_password(new_password, current_password)
    Heroku::Conn::Put("/account/password", body: {
      password:             new_password,
      current_password: current_password
    }.to_json)
    true
  end
end
