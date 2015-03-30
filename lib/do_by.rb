require "do_by/version"
require "do_by/repository"
require "do_by/handlers"
require "rugged"
require "date"

module DoBy
  class << self
    attr_writer :enable,
                :default_due_in_days,
                :raise_only_for_culprit

    def enabled?
      @enable ||= ENV['ENABLE_DO_BY']
    end

    def default_due_in_days
      @default_due_in_days ||= 30
    end

    def raise_only_for_culprit
      @raise_only_for_culprit ||= false
    end

    def default_handler
      DueIn
    end

  end

  class LateTask < RuntimeError; end
  class NoDueDateTask < RuntimeError; end

  class Note
    def initialize(*args)
      @description = args.first
      @options = args.last.is_a?(Hash) ? args.pop : {}
      puts args
      puts @options

      matching_handlers = DoBy::HANDLERS.select{|handler| handler.handles?(*args, @options)}
      raise ArgumentError.new("can't give both due date and due in") if matching_handlers.size > 1
      handler = if matching_handlers.any?
                  matching_handlers.first.new(*args, @options)
                else
                  DoBy::DEFAULT_HANDLER.new(*args, @options)
                end

      raise LateTask.new("TODO: #{@description} \n#{handler.overdue_message} \n#{location_msg}") if handler.due?
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