require "rails_helper"

RSpec.describe OperationHistory, type: :model do
  it { should belong_to :user }

  describe "validations" do
    it { should validate_presence_of(:sleep_at) }
    it { should validate_presence_of(:wakeup_at).on(:update) }
  end

  describe "#init_length_of_sleep" do
    let(:now) { Time.current }
    let(:operation_history) do
      FactoryBot.create(:operation_history, sleep_at: now, wakeup_at: now + 2.seconds)
    end

    context "When assign sleep_at and wakeup_at value" do
      it "return calculated length_of_sleep" do
        expect(operation_history.length_of_sleep).to eq(2)
      end
    end
  end
end
