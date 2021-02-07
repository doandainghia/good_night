require "rails_helper"

RSpec.describe User, type: :model do
  it { should have_many(:followers).through(:reverse_relationships) }
  it { should have_many(:reverse_relationships) }
  it { should have_many(:followed_users).through(:relationships) }
  it { should have_many(:relationships) }

  describe "#following?" do
    let(:user) { FactoryBot.create :user }
    let(:other_user) { FactoryBot.create :user }

    context "when user didn't follow other_user" do
      it "return false" do
        expect(user.following? other_user.id).to eq (false)
      end
    end

    context "when user followed other_user" do
      it "return true" do
        FactoryBot.create :relationship, follower: user, followed: other_user
        expect(user.following? other_user.id).to eq (true)
      end
    end
  end
end
