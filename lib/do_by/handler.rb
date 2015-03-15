module DoBy
  class Handler
    class << self
      def handles?(options)
        !!options[options_key]
      end

      def default_options; Hash.new; end
      attr_accessor :options_key
    end

    attr_reader :due_value, :options
    def initialize(options)
      @options = options
      @due_value = options[self.class.options_key]
    end

    def due?; raise 'implement!' end
  end

  class DueInHandler < Handler
    self.options_key = :due_in

    def self.default_options
      {:due_in => DoBy.default_due_in_days}
    end

    alias_method :due_in, :due_value

    def due?
      relative_path = options[:todo_file].sub repo.workdir, ''

      if repo.index.diff(:paths => [relative_path]).deltas.empty?
        blame = Rugged::Blame.new(repo, relative_path, :min_line => options[:todo_line], :max_line => options[:todo_line]).first
        time = blame[:final_signature][:time]
        @overdue_days = (Date.today - time.to_date).to_i - due_in
      @culprit_name = blame[:final_signature][:name]
      @culprit_email = blame[:final_signature][:email]
        return @overdue_days >= 1
      else return false
      end

    rescue Rugged::RepositoryError, Rugged::OSError
      return false
    end

    def overdue_message
      "is #{@overdue_days} days overdue \nCulprit: #{@culprit_name} - #{@culprit_email}"
    end

    private
    def repo
      @repo ||= Rugged::Repository.discover(options[:todo_file])
    end
  end

  class DueByHandler < Handler
    self.options_key = :due_date
    alias_method :due_date, :due_value
    def due?
      Date.parse(due_date) < Date.today
    end

    def overdue_message
      "is overdue since #{due_date}"
    end
  end
end