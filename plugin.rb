# name: solutions-likes-count-plugin
# about: A plugin to show solutions and likes count under each post
# version: 0.1
# authors: Osama Sayegh
# url: https://github.com/OsamaSayegh/solutions-likes-count-plugin

enabled_site_setting :enable_solutions_and_likes_count_plugin

register_asset "stylesheets/solutions-likes-plugin.scss"

after_initialize do

  if SiteSetting.enable_solutions_and_likes_count_plugin
    require_dependency 'post_serializer'
    class ::PostSerializer
      attributes :accepted_answers_count, :likes_recieved_count, :user_trust_level, :attendance_rate
      def accepted_answers_count
        if poster_summary.present?
          @summary.solved_count
        end
      end

      def likes_recieved_count
        if poster_summary.present?
          @summary.likes_received
        end
      end

      def user_trust_level
        object.user.trust_level if object&.user
      end

      def attendance_rate
        if poster_summary.present? && object&.user
          days_visited = @summary.days_visited
          join_date = object.user.created_at.to_date
          now_date = Time.now.to_date
          days_between_dates = (now_date - join_date).to_i
          attendance = (days_visited.to_f / days_between_dates) * 100
          attendance
        end
      end

      private
        def poster_summary
          if object&.user
            @summary ||= UserSummary.new(object.user, scope)
          end
        end
    end
  end
end
