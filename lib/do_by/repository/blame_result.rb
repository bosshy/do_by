module DoBy
  class Repository
    class BlameResult

      # empty blame used instead of nil
      def self.none
        @none ||= new()
      end

      def initialize(blame_hash={})
        @blame_hash = blame_hash
      end

      def commit_date
        @blame_hash[:time] ? @blame_hash[:time].to_datetime : DateTime.now
      end

      def author
        @blame_hash[:name] || 'unknown'
      end

      def email
        @blame_hash[:email] || 'unknown'
      end

      def current_user_responsible?
        email == Repository.current_user[:email]
      end

      def exists?
        @blame_hash.any?
      end
    end
  end
end
