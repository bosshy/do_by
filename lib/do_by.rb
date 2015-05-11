require "do_by/version"
require "do_by/note"
require "do_by/repository"
require "do_by/handlers"
require "rugged"
require "date"

module DoBy
  class << self
    attr_writer :enable,
                :default_due_in_days,
                :raise_only_for_author

    def enabled?
      @enable ||= ENV['ENABLE_DO_BY']
    end

    def default_due_in_days
      @default_due_in_days ||= 30
    end

    def raise_only_for_author?
      @raise_only_for_author ||= false
    end

    def default_handler
      DueIn
    end

  end
end


module Kernel
  def TODO(*args)
    return unless DoBy.enabled?
    todo_location = caller[0].match(/(^.*?):(\d*)/)
    todo_file = todo_location[1]
    todo_line = todo_location[2].to_i
    todo_opts = {:todo_file => todo_file, :todo_line => todo_line}
    args.last.is_a?(Hash) ? args.last.merge!(todo_opts) : args.push(todo_opts)

    DoBy::Note.new(*args)
  end
  alias_method :FIXME, :TODO
  alias_method :OPTIMIZE, :TODO
end