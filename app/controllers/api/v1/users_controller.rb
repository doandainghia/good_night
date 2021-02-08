module Api
  module V1
    class UsersController < ApiController
      before_action :get_current_user

      def operation_histories
        operation_histories = @current_user.operation_histories.newest
        render_multiple_object true, operation_histories, OperationHistorySerializer
      end

      def operation_history_of_friends
        followed_user_ids = @current_user.followed_user_ids
        operation_histories = OperationHistory.last_week.order_by_length_of_sleep(followed_user_ids).includes(:user)
        render_multiple_object true, operation_histories, OperationHistorySerializer
      end

      def record_sleep_at
        operation_history = @current_user.operation_histories.new sleep_at: Time.current

        if operation_history.save
          render json: { success: true, data: OperationHistorySerializer.new(operation_history) }
        else
          render json: { success: false, errors: operation_history.errors }
        end
      end

      def record_wakeup_at
        operation_history = @current_user.operation_histories.find params[:operation_history_id]
        operation_history.assign_attributes wakeup_at: Time.current

        if operation_history.save
          render json: { success: true, data: OperationHistorySerializer.new(operation_history) }
        else
          render json: { success: false, errors: operation_history.errors }
        end
      end

      def follow
        relationship = @current_user.relationships.new followed_id: params[:other_user_id]

        if relationship.save
          render json: { success: true, data: RelationshipSerializer.new(relationship) }
        else
          render json: { success: false, errors: relationship.errors }
        end
      end

      def unfollow
        if @current_user.following? params[:other_user_id]
          @current_user.relationships.find_by(followed_id: params[:other_user_id]).destroy
          render json: { success: true }
        else
          render json: { success: false, errors: "you have unfollowed already or didn't follow before" }
        end
      end

      private

      def get_current_user
        @current_user = User.find params[:id]
      end
    end
  end
end
