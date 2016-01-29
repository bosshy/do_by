require 'do_by/repository/blame'

module DoBy
  class Repository
    class << self
      attr_reader :project_repository

      def ensure_initialized_repository(filepath)
        if defined?(@project_repository)
          @project_repository
        else
          @project_repository = begin
            Rugged::Repository.discover(filepath)
          rescue Rugged::RepositoryError
            STDERR.puts "#{filepath} is not in a git repository"
            STDERR.puts "due_in x (days) TODOs will be ignored"
            nil
          end
        end
      end

      def blame(options)
        ensure_initialized_repository(options[:todo_file])
        return Blame.none unless project_repository

        relative_path = path_relative_to_workdir(options[:todo_file])
        return Blame.none if uncommitted_changes_in_file?(relative_path)

        blame_hash = Rugged::Blame.new(project_repository, relative_path,
                                       :min_line => options[:todo_line], :max_line => options[:todo_line]).
            first[:final_signature]

        Blame.new(blame_hash)

      rescue Rugged::RepositoryError, Rugged::OSError, StandardError
        Blame.none
      end

      def current_user
        @current_user ||= {:name => git_conf['user.name'], :email => git_conf['user.email']}
      end

      private
      def uncommitted_changes_in_file?(relative_path)
        project_repository.index.diff(:paths => [relative_path]).deltas.any?
      end

      def path_relative_to_workdir(absolute_path)
        absolute_path.sub(project_repository.workdir, '') if project_repository
      end

      def git_conf
        @git_conf ||= project_repository ? project_repository.config : {}
      end
    end
  end
end
