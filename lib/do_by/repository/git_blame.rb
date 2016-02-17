require 'forwardable'
module DoBy
  class Repository
    class GitBlame
      extend Forwardable
      def_delegator :@blame_hsh, :[]
      attr_reader :file, :line


      def initialize(file, line)
        @file = file
        @line = line
      end

      def blame
        blame_str = exec_blame
        blame_str ? parse_blame(blame_str) : nil
      end

      private
      def exec_blame
        `cd #{Repository.toplevel_dir}; #{DoBy.git_cmd} blame -p -L #{line},#{line} #{file} 2> /dev/null`
      end

      # TODO[@until 2015-10-10]: make shiny and pretty
      def parse_blame(blame_str)
        @blame_hsh = {}
        blame_str.split("\n").each do |line|
          {:author => :name, :'author-mail' => :email, :'author-time' => :time}.each do |git_attr, hash_key|
            if match = /#{git_attr} <?([^>]*)/.match(line)
              @blame_hsh[hash_key] = match.captures.first
            end
          end
        end
        @blame_hsh[:time] = Time.at(@blame_hsh[:time].to_i).to_datetime if @blame_hsh[:time]
        @blame_hsh
      end
    end
  end
end