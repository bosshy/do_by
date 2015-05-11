module DoBy
  module Handler
    class DueIn < Base

      self.options_key = :due_in

      def self.default_options
        {:due_in => DoBy.default_due_in_days}
      end

      alias_method :due_in, :due_value

      def due?
        return overdue_days >= 1
      end

      def overdue_message
        "is #{overdue_days} days overdue #{culprit_msg}"
      end

      def overdue_days
        @overdue_days ||= (Date.today - blame.commit_date).to_i - due_in
      end

    end
  end
end
