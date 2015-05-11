module DoBy

  class LateTask < RuntimeError; end
  class NoDueDateTask < RuntimeError; end

  class Note

    attr_reader :handler


    def initialize(*args)
      @description = args.first
      @options = args.last.is_a?(Hash) ? args.pop : {}

      matching_handlers = DoBy::HANDLERS.select{|handler| handler.handles?(*args, @options)}
      raise ArgumentError.new("can't give both due date and due in") if matching_handlers.size > 1
      @handler = if matching_handlers.any?
                   matching_handlers.first.new(*args, @options)
                 else
                   DoBy::DEFAULT_HANDLER.new(*args, @options)
                 end

      raise LateTask.new("TODO: #{@description} \n#{handler.overdue_message} \n#{location_msg}") if raise_conditions_met?
    end

    private
    def location_msg
      "File: #{@options[:todo_file]} \nLine: #{@options[:todo_line]}"
    end

    def raise_conditions_met?
      handler.due? and handler.current_user_responsible?
    end
  end
end