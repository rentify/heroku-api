require 'heroku/api/password'
require 'heroku/api/rate_limits'
require 'heroku/model/model_helper'

module Heroku
  module Model
    class Account < Struct.new(
      :parent,
      :id,
      :email,
      :verified,
      :allow_tracking,
      :beta,
      :last_login,
      :updated_at,
      :created_at
    )

      include Heroku::Model::ModelHelper
      include Heroku::API::Password
      include Heroku::API::RateLimits

      def inspect
        "#<#{self.class.name} #{identifier}>"
      end

      def initialize(params = {})
        super(*struct_init_from_hash(params))
      end

      def patchable
        sub_struct_as_hash(:email, :allow_tracking)
      end

      def identifiable
        sub_struct_as_hash(:id, :email)
      end

      def save
        parent.update_account(self)
      end

    end
  end
end
