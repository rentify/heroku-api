require 'heroku/conn'

module Heroku
  class API
    module Password
      def update_password(new_password, current_password)
        Heroku::Conn::Put("/account/password", body: {
          password:             new_password,
          current_password: current_password
        }.to_json)
        true
      end
    end
  end
end
