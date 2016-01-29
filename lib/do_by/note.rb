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
    end

    def raise_if_overdue
      raise LateTask.new(overdue_msg) if overdue?
    end

    def overdue_msg
      "TODO: #{@description} \n#{overdue_info} \n#{location_msg}"
    end

    def overdue_info
      handler.overdue_info
    end

    def culprit_info
      handler.culprit_info
    end

    def overdue?
      handler.due? and handler.current_user_responsible?
    end

    def location_msg
      "File: #{@options[:todo_file]} \nLine: #{@options[:todo_line]}"
    end


  end
end