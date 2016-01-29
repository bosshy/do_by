module DoBy
  module Handler

    # format: TODO 'todo description', :due_date => '2015-10-31'
    class DueBy < Base
      self.options_key = :due_date
      alias_method :due_date, :due_value

      def due?
        Date.parse(due_date) < Date.today
      end

      def overdue_info
        "is overdue since #{due_date}"
      end
    end

    # format: TODO 'todo description', '2015-10-31'
    class DueBy2ndArgument < DueBy

      def initialize(*args, options)
        super(*args, options)
        @due_value = args[1]
      end

      def self.handles?(*args, options)
        return false unless args[1].is_a?(String)
        year, month, day = args[1].split '-'
        return false unless year && month && day

        Date.valid_date? year.to_i, month.to_i, day.to_i
      end

    end
  end
end
