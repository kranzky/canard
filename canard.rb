module Canard
  class BadQuack < StandardError; end
  Q =
    Class.new do
      def self.<(name)
        raise BadQuack unless name.is_a?(String)
        nil
      end
    end
end
