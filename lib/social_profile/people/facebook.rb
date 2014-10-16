require "fb_graph"

module SocialProfile
  module People
    class Facebook < Person
      FRIENDS_FQL = "SELECT friend_count FROM user WHERE uid=me()"
      FIRST_POST_FQL = "SELECT created_time FROM stream WHERE source_id = me() AND created_time < {date} limit 1"
      LAST_POSTS_FIELDS = [
        "comments.fields(created_time).limit(1).summary(true)", 
        "likes.limit(1).fields(id).summary(true)",
        "created_time",
        "shares"
      ]
      POST_FIELDS = [
        "comments.fields(created_time).limit(1).summary(true)", 
        "likes.limit(1).fields(id).summary(true)",
        "created_time",
        "shares"
      ]

      # Find album by id
      def fetch_album(album_id)
        ::FbGraph::Album.fetch(album_id, :access_token => access_token)
      end
      
      # Create new album id
      def album!(options = {})
        user.album!(options)
      end

      # Get friends count
      #
      def friends_count
        @friends_count ||= fetch_friends_count
      end

      # Get followers count
      #
      def followers_count
        @followers_count ||= followers(:limit => 1).total_count
      end

      def fetch_friends_count
        response = FbGraph::Query.new(FRIENDS_FQL).fetch(:access_token => access_token)

        response = response.first if response.is_a?(Array)
        return nil if response.is_a?(Hash) && response["friend_count"].blank?

        response["friend_count"].to_i
      end

      # Check if exists any post before current year 
      #
      def first_post_exists?(year)
        timestamp = Time.new(year, 1, 1).utc.to_i

        _sql = FIRST_POST_FQL.gsub('{date}', timestamp.to_s)
        response = FbGraph::Query.new(_sql).fetch(:access_token => access_token)

        response = response.first if response.is_a?(Array)
        return nil if response.nil? || (response.is_a?(Hash) && response["created_time"].blank?)

        response["created_time"].to_i
      end

      # Get last limited posts from feed with comments, shares and likes counters
      #
      def last_posts(limit, options = {})
        fields = options[:fields] || LAST_POSTS_FIELDS

        user.feed(:fields => fields.join(","), :limit => limit)        
      end

      # Get last post by days from feed with comments, shares and likes counters
      #
      def last_post_by_days(days, options={})
        date = (options[:date_end] || Time.now) - days.days
        limit = options[:limit] || 100
        max_iteration = options[:max_iteration] || 100
        iteration = 0

        posts = collection = last_posts(limit, options)
        return [] if posts.blank?
        
        last_created_time = posts.last.created_time

        while last_created_time > date && !last_created_time.blank? && iteration < max_iteration
          iteration += 1
          collection = collection.next
          posts += collection
          last_created_time = posts.last.created_time
        end

        posts.select { |p| p.created_time > date }
      end

      # Get all friends list
      #
      def friends(options={})
        limit = options[:limit] || 5000
        user.friends(:limit => limit)
      end

      # Get all followers list
      #
      def followers(options={})
        limit = options[:limit] || 5000
        fetch_all = options[:fetch_all] || false
        iteration = 0

        _followers = collection = user.subscribers(:limit => limit)
        max_iteration = _followers.total_count / limit + 1

        if fetch_all
          while iteration < max_iteration
            iteration += 1
            collection = collection.next
            _followers += collection
          end
        end

        _followers
      end

      # Get post from feed with comments, shares and likes counters
      #
      def fetch_post(post_uid, options = {})
        fields = options[:fields] || POST_FIELDS

        ::FbGraph::Post.fetch(post_uid, :fields => fields.join(","), :access_token => access_token)    
      end

      protected
      
        def user
          @user ||= ::FbGraph::User.me(access_token)
        end
    end
  end
end