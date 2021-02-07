require "rails_helper"

describe Api::V1::UsersController do
  let(:user) { FactoryBot.create :user }
  let(:other_user) { FactoryBot.create :user }
  let(:relationship) { FactoryBot.create :relationship, followed: other_user, follower: user }
  let(:last_week_time) { Date.today.at_end_of_week.last_week(:tuesday).end_of_day }
  let!(:operation_history) { FactoryBot.create :operation_history, user: user}
  let!(:operation_history_last_week1) do
    FactoryBot.create :operation_history, user: other_user, sleep_at: last_week_time,
                      wakeup_at: last_week_time + 1.seconds
  end
  let!(:operation_history_last_week2) do
    FactoryBot.create :operation_history, user: other_user, sleep_at: last_week_time + 2.seconds,
                      wakeup_at: last_week_time + 4.seconds
  end
  let!(:operation_history_last_week3) do
    FactoryBot.create :operation_history, user: other_user, sleep_at: last_week_time + 5.seconds,
                      wakeup_at: last_week_time + 8.seconds
  end

  describe "GET #operation_histories" do
    context "when send params id of user doesn't exist" do
      it "returns status code 404" do
        get :operation_histories, params: { id: 0 }
        expect(response).to have_http_status(404)
      end
    end

    context "when user exists" do
      let!(:operation_history_later) { FactoryBot.create :operation_history, user: user }
      before { get :operation_histories, params: { id: user.id } }

      it "returns status code 200" do
        expect(response).to have_http_status(:success)
      end

      it "JSON body response order by created_at" do
        ordered_operation_histories = [
          OperationHistorySerializer.new(operation_history),
          OperationHistorySerializer.new(operation_history_later)
        ]
        expect(response.body).to eq({ success: true, data: ordered_operation_histories }.to_json)
      end
    end
  end

  describe "GET #operation_history_of_friends" do
    context "when send params id of user doesn't exist" do
      it "returns status code 404" do
        get :operation_history_of_friends, params: { id: 0 }
        expect(response).to have_http_status(404)
      end
    end

    context "when user exists" do
      subject { get :operation_history_of_friends, params: { id: user.id } }

      it "returns http code 200" do
        is_expected.to be_successful
      end

      it "JSON body response order by length_of_sleep" do
        relationship
        subject
        ordered_operation_histories = [
          OperationHistorySerializer.new(operation_history_last_week3),
          OperationHistorySerializer.new(operation_history_last_week2),
          OperationHistorySerializer.new(operation_history_last_week1),
        ]

        expect(response.body).to eq({
          success: true, data: ordered_operation_histories
        }.to_json)
      end
    end
  end

  describe "POST #record_sleep_at" do
    subject { post :record_sleep_at, params: { id: user.id } }

    it "JSON body response contains expected sleep_at" do
      expect { subject }.to change(OperationHistory, :count).by(1)
      expect(response.body).to eq({
        success: true, data: OperationHistorySerializer.new(user.operation_histories.last)
      }.to_json)
    end
  end

  describe "POST #record_wakeup_at" do
    it "JSON body response contains expected sleep_at" do
      post :record_wakeup_at, params: { id: user.id, operation_history_id: operation_history.id }
      expect(response.body).to eq({
        success: true, data: OperationHistorySerializer.new(operation_history.reload)
      }.to_json)
    end
  end

  describe "POST #follow" do
    subject { post :follow, params: { id: user.id, other_user_id: other_user.id } }

    context "When user has followed other_user already" do
      it "return errors json" do
        relationship
        subject
        json_response = JSON.parse(response.body)

        expect(json_response).to eq(
          { "errors" => { "followed_id" => ["has already been taken"] }, "success" => false}
        )
      end
    end

    it "creates a relationship" do
      expect { subject }.to change(Relationship, :count).by(1)
    end

    it "JSON body response contains expected last_relationship" do
      subject
      last_relationship = user.relationships.last
      expect(response.body).to eq({
        success: true, data: RelationshipSerializer.new(last_relationship)
      }.to_json)
    end
  end

  describe "POST #unfollow" do
    subject { post :unfollow, params: { id: user.id, other_user_id: other_user.id } }

    context "When user has unfollowed other_user already or didn't follow before" do
      it "return errors json" do
        subject
        json_response = JSON.parse(response.body)

        expect(json_response).to eq(
          { "errors" => "you have unfollowed already or didn't follow before", "success" => false }
        )
      end
    end

    it "destroys a relationship" do
      relationship
      subject
      expect { subject }.to change(Relationship, :count).by(0)
    end

    it "JSON body response contains success json" do
      relationship
      subject
      json_response = JSON.parse(response.body)

      expect(json_response).to eq({ "success" => true })
    end
  end
end
