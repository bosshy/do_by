require "do_by/version"
require "do_by/note"
require "do_by/repository"
require "do_by/handlers"
require "date"
require "yaml"
require "rubocop/cop/do_by/expired_todos" if defined?(RuboCop)

module DoBy
  class << self
    attr_writer :enable,
                :default_due_in_days,
                :raise_only_for_author,
                :git_cmd

    def enabled?
      unless @enable.nil?
        @enabled
      else
        @enabled = YAML.load(ENV['ENABLE_DO_BY'].to_s)
      end
    end

    def default_due_in_days
      @default_due_in_days ||= 30
    end

    def git_cmd
      @git_cmd ||= 'git'
    end

    def raise_only_for_author?
      unless @raise_only_for_author.nil?
        @raise_only_for_author
      else
        @raise_only_for_author = false
      end
    end

    def default_handler
      DueIn
    end

    def on_due &block
      @due_action = block
    end

    def due_action
      @due_action ||= ->(due_task) { raise(due_task) }
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

    DoBy::Note.new(*args).raise_if_overdue
  end
  alias_method :FIXME, :TODO
  alias_method :OPTIMIZE, :TODO
end
