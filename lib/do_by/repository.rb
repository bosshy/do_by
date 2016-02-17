require 'do_by/repository/blame_result'
require 'do_by/repository/git_blame'

module DoBy
  class Repository
    class << self
      attr_reader :toplevel_dir

      def blame(options)
        ensure_git_repo_presence(options[:todo_file])
        return BlameResult.none unless is_git_repo?

        blame_hash = GitBlame.new(options[:todo_file], options[:todo_line]).blame
        blame_hash.any? ? Repository::BlameResult.new(blame_hash) : Repository::BlameResult.none
      end

      def current_user
        @current_user ||= {:name => git_conf['user.name'], :email => git_conf['user.email']}
      end

      def is_git_repo?
        !!toplevel_dir
      end
      private
      def ensure_git_repo_presence(filepath)
        if defined?(@toplevel_dir)
          @toplevel_dir
        else
          @toplevel_dir = discover_toplevel_dir(filepath)
        end
      end

      def discover_toplevel_dir(filepath)
        dir = File.dirname(filepath)
        `cd #{dir}; #{DoBy.git_cmd} rev-parse --show-toplevel 2> /dev/null`.split("\n").first
      end

      def git_conf
        @git_conf ||= GitConf.conf
      end
    end

    class GitConf
      class << self
        def conf
          cd_into_repo = Repository.is_git_repo? ? "cd #{Repository.toplevel_dir};" : nil
          conf = `#{cd_into_repo} #{DoBy.git_cmd} config --list`
          parse_conf(conf)
        end

        private
        def parse_conf(conf_str)
          conf_hsh = {}
          conf_str.split("\n").each do |line|
            match = /(?<k>.*)=(?<v>.*)/.match(line)
            conf_hsh[match[:k]] = match[:v] if match
          end
          conf_hsh
        end
      end
    end
  end
end
