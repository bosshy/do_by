module DoBy
  module Handler
    class Base
      class << self
        def handles?(*args, options)
          !!options[options_key]
        end

        def default_options; Hash.new; end
        attr_accessor :options_key
      end

      attr_reader :due_value, :options
      def initialize(*args, options)
        @options = self.class.default_options.merge(options)
        @due_value = @options[self.class.options_key]
      end

      def due?; raise 'implement!' end


      def culprit_msg
        " \nCulprit: #{culprit[:name]} - #{culprit[:email]}" if culprit
      end

      private
      def culprit
        @culprit ||= {:name => blame[:name], :email => blame[:email]} if blame
      end

      def current_user_responsible?
        return true unless DoBy.raise_only_for_author?

        blame.current_user_responsible?
      end

      def blame
        @blame ||= DoBy::Repository.blame(options)
      end

    end
  end
end