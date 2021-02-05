require "rails_helper"

RSpec.describe OperationHistory, type: :model do
  describe "validations" do
    it { should validate_presence_of(:sleep_at) }
    it { should validate_presence_of(:wakeup_at).on(:update) }
  end
end
