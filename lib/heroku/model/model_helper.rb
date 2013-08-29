module Heroku
  module Model
    module ModelHelper
      def struct_init_from_hash(hash)
        hash.values_at(*members.map(&:to_s))
      end

      def sub_struct_as_hash(*params)
        Hash[params.map { |k| [k, send(k)] }]
      end

      def identifier
        identifiable.to_a.map { |k,v| "#{k}=#{v.inspect}"}.join(', ')
      end
    end
  end
end
