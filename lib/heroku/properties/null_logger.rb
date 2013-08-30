module Heroku
  class Properties
    class NullLogger

      def info(   msg); end
      def warn(   msg); end
      def debug(  msg); end
      def unknown(msg); end

      def tagged(tag) # yields
        yield
      end

    end
  end
end
