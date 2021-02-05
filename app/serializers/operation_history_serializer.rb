class OperationHistorySerializer < ActiveModel::Serializer
  attributes :id, :sleep_at, :wakeup_at, :created_at, :distance_time, :user

  def user
    UserSerializer.new object.user
  end

  def sleep_at
    object.sleep_at.strftime("%Y-%m-%d %H:%M:%S") if object.sleep_at
  end

  def wakeup_at
    object.wakeup_at.strftime("%Y-%m-%d %H:%M:%S") if object.wakeup_at
  end

  def created_at
    object.created_at.strftime("%Y-%m-%d %H:%M:%S") if object.created_at
  end
end
