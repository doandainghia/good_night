class RelationshipSerializer < ActiveModel::Serializer
  attributes :id, :follower, :followed

  def follower
    UserSerializer.new object.follower
  end

  def followed
    UserSerializer.new object.followed
  end
end
