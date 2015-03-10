require "do_by/version"
require "rugged"
require "date"

module DoBy
  class << self
    attr_writer :enable, :default_due_in_days

    def enabled?
      !!(@enable || ENV['ENABLE_DO_BY'])
    end

    def default_due_in_days
      @default_due_in_days || 30
    end

    def default_handler
      DueInHandler
    end

  end

  class LateTask < RuntimeError; end
  class NoDueDateTask < RuntimeError; end

  class Handler
    class << self
      def handles?(options)
        !!options[options_key]
      end
      attr_accessor :options_key
    end

    attr_accessor :due_value
    def initialize(options)
      self.due_value = options[self.class.options_key]
    end

    def due?; raise 'implement!' end
  end

  class DueInHandler < Handler
    self.options_key = :due_in

    alias_method :due_in, :due_value

    def due?
      caller_unparsed = caller[2]
      match = caller_unparsed.match(/(^.*?):(\d*)/)
      caller_file = match[1]
      caller_line = match[2].to_i

      repo = Rugged::Repository.discover(caller_file)

      work_dir = repo.workdir
      relative_path = caller_file.sub work_dir, ''

      blame = Rugged::Blame.new repo, relative_path, :min_line => caller_line, :max_line => caller_line
      time = blame.first[:final_signature][:time]
      @overdue_days = (Date.today - time.to_date).to_i - due_in
      return @overdue_days >= 1

    rescue Rugged::RepositoryError, Rugged::OSError
      return false
    end

    def overdue_message
      "is overdue by #{@overdue_days} days"
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

  class Note
    HANDLERS = [DoBy::DueInHandler, DoBy::DueByHandler]
    def initialize(description, options={})

      matching_handlers = HANDLERS.select{|handler| handler.handles?(options)}
      raise ArgumentError.new("can't give both due date and due in") if matching_handlers.size > 1
      handler_class = matching_handlers.first || DoBy.default_handler
      handler = handler_class.new(options)

      raise LateTask.new("#{description} #{handler.overdue_message}") if handler.due?
    end
  end
end


module Kernel
  def TODO(*args)
    return unless DoBy.enabled?
    DoBy::Note.new(*args)
  end
  alias_method :FIXME, :TODO
  alias_method :OPTIMIZE, :TODO
end
