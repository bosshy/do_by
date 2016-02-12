module RuboCop
  module Cop
    module DoBy

      # Usage:
      # bundle exec rubocop --require do_by --only DoBy/ExpiredTodos --cache false
      # disabling the rubocop cache is important, otherwise todos are only checked on file changes
      class ExpiredTodos < Cop

        def investigate(processed_source)
          file_path = processed_source.buffer.name

          processed_source.comments.each do |comment|

            file_line = comment.loc.line
            cl = Comment.new(comment.text)
            next unless cl.todo?

            note = case
                     when cl.due_by?
                       ::DoBy::Note.new(cl.note, :todo_file => file_path, :todo_line =>file_line, :due_date => cl.due_by_val)
                     when cl.due_in?
                       ::DoBy::Note.new(cl.note, :todo_file => file_path, :todo_line =>file_line, :due_in => cl.due_in_val)
                     when cl.expires?
                       ::DoBy::Note.new(cl.note, :todo_file => file_path, :todo_line =>file_line, :due_in => ::DoBy.default_due_in_days)
                     else
                       nil
                   end
            if note && note.overdue?
              add_offense(comment, :expression, "#{note.overdue_info} - #{note.culprit_info}")
            end
          end
        end

        class Comment
          TODO_KEYWORDS = %w(TODO FIXME OPTIMIZE)
          DUE_IN_KEYWORDS = %w(due_in within)
          DUE_BY_KEYWORDS = %w(due_by due_date until)
          EXPIRES_KEYWORD = 'expires'

          DUE_BY_KEYWORDS_EXP = DUE_BY_KEYWORDS.join('|')
          DUE_IN_KEYWORDS_EXP = DUE_IN_KEYWORDS.join('|')

          attr_reader :text
          def initialize(text)
            @text = text
          end

          def due_by?
            !!due_by_match
          end

          def due_in?
            !!due_in_match
          end

          def note
            todo_match && todo_match[:note]
          end

          def expires?
            annotation &&
                (/#{EXPIRES_KEYWORD}/.match(annotation) || due_by? || due_in?)
          end

          def due_by_val
            due_by_match ? due_by_match[1] : nil
          end

          def due_in_val
            due_in_match ? due_in_match[1].to_i : nil
          end

          def todo?
            todo_match && TODO_KEYWORDS.include?(todo_match[:first_word])
          end

          private
          # e.g. [@until 2016-06-30]
          def due_by_match
            @due_by_match ||= /@(?:#{DUE_BY_KEYWORDS_EXP})\s+(\d{4}-\d{2}-\d{2})/.match(annotation)
          end

          # e.g. [@within 30]
          def due_in_match
            @due_in_match ||= /@(?:#{DUE_IN_KEYWORDS_EXP})\s+(\d+)/.match(annotation)
          end

          def todo_match
            return @_todo_match if defined?(@_todo_match)
            # e.g. FIRST_WORD[ @annotation ]: Note
            match = @text.match(/^(# *)(?<first_word>[A-Za-z]+)\s*(?<annotation>\[\s*@[\w\s-]*\])?(\s*:?)?(\s+)?(?<note>\S.*)?/)
            @_todo_match = match ? match : nil
          end

          def annotation
            todo_match && todo_match[:annotation]
          end
        end
      end
    end
  end
end

