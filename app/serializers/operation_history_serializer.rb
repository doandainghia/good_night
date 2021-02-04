class OperationHistorySerializer < ActiveModel::Serializer
  attributes :id, :sleep_at, :wakeup_at, :created_at, :distance_time, :user

  def user
    UserSerializer.new object.user
  end
end
