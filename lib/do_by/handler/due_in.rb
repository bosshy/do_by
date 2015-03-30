module DoBy
  module Handler
    class DueIn < Base

      self.options_key = :due_in

      def self.default_options
        {:due_in => DoBy.default_due_in_days}
      end

      alias_method :due_in, :due_value

      def due?

        if blame
          time = blame[:time]
          @overdue_days = (Date.today - time.to_date).to_i - due_in
          return @overdue_days >= 1

        else return false
        end
      end

      def overdue_message
        "is #{@overdue_days} days overdue #{culprit_msg}"
      end

    end
  end
end