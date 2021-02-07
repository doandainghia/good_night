require "rails_helper"

RSpec.describe Relationship, type: :model do
  it { should belong_to :follower }
  it { should belong_to :followed }

  describe "validations" do
    it { should validate_presence_of(:followed_id) }
    it { should validate_uniqueness_of(:followed_id).scoped_to(:follower_id) }
  end
end
