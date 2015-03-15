require "do_by/version"
require "do_by/handler"
require "rugged"
require "date"

module DoBy
  HANDLERS = [DoBy::DueInHandler, DoBy::DueByHandler]
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

  class Note
    def initialize(description, options={})
      @description, @options = description, options

      matching_handlers = DoBy::HANDLERS.select{|handler| handler.handles?(options)}
      raise ArgumentError.new("can't give both due date and due in") if matching_handlers.size > 1
      handler = if matching_handlers.any?
                  matching_handlers.first.new(options)
                else
                  DoBy.default_handler.new(options.merge(DoBy.default_handler.default_options))
                end

      raise LateTask.new("TODO: #{description} \n#{handler.overdue_message} \n#{location_msg}") if handler.due?
    end

    private
    def location_msg
      "File: #{@options[:todo_file]} \nLine: #{@options[:todo_line]}"
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