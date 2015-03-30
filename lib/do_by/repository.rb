module DoBy
  class Repository
    class << self
      attr_reader :project_repository

      def project_repository=(repo_path)
        @project_repository = Rugged::Repository.discover(repo_path)
      rescue false
      end

      def blame(options)
        @project_repository ||= Rugged::Repository.discover(options[:todo_file])
        relative_path = path_relative_to_workdir(options[:todo_file])

        if no_uncommitted_changes_in_file?(relative_path)
          Rugged::Blame.new(project_repository, relative_path,
                            :min_line => options[:todo_line], :max_line => options[:todo_line]).
              first[:final_signature]
        end
      rescue Rugged::RepositoryError, Rugged::OSError, StandardError
        nil
      end

      def current_user
        @current_user ||= {:name => git_conf['user.name'], :email => git_conf['user.email']}
      end

      private
      def no_uncommitted_changes_in_file?(relative_path)
        project_repository.index.diff(:paths => [relative_path]).deltas.empty?
      end

      def path_relative_to_workdir(absolute_path)
        absolute_path.sub(project_repository.workdir, '')
      end

      def git_conf
        @git_conf ||= project_repository.config
      end

    end
  end
end
