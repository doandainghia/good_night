require "rails_helper"

describe Api::V1::UsersController do
  let(:user) { FactoryBot.create :user }
  let(:other_user) { FactoryBot.create :user }
  let(:relationship) { FactoryBot.create :relationship, followed: other_user, follower: user }
  let!(:now) { Time.current }
  let(:two_seconds_later) { now + 2.seconds }
  let(:formated_now) { now.strftime("%Y-%m-%d %H:%M:%S") }
  let(:last_week_time) { Date.today.at_end_of_week.last_week(:tuesday).end_of_day }
  let!(:operation_history) { FactoryBot.create :operation_history, user: user, sleep_at: now }
  let!(:operation_history_last_week) do
    FactoryBot.create :operation_history, user: other_user, sleep_at: last_week_time,
                      wakeup_at: last_week_time + 2.seconds
  end

  describe "GET #operation_histories" do
    it "raise record not found" do
      get :operation_histories, params: { id: 0 }
      expect(response.status).to eq(404)
    end

    it "JSON body response contains expected operation_history" do
      get :operation_histories, params: { id: user.id }

      json_response = JSON.parse(response.body)

      expect(json_response).to eq(
        {
          "data" => [
            {
              "created_at" => formated_now,
              "length_of_sleep" => nil,
              "id" => operation_history.id,
              "sleep_at" => formated_now,
              "user" => {
                "id" => user.id,
                "name" => user.name
              },
              "wakeup_at" => nil
            }
          ],
          "success" => true,
        }
      )
    end
  end

  describe "GET #operation_history_of_friends" do
    it "raise record not found" do
      get :operation_history_of_friends, params: { id: 0 }
      expect(response.status).to eq(404)
    end

    it "JSON body response contains expected operation_history_last_week" do
      relationship
      get :operation_history_of_friends, params: { id: user.id }
      formated_last_week_time = last_week_time.strftime("%Y-%m-%d %H:%M:%S")
      json_response = JSON.parse(response.body)

      expect(json_response).to eq(
        {
          "data" => [
            {
              "created_at" => formated_now,
              "length_of_sleep" => 2,
              "id" => operation_history_last_week.id,
              "sleep_at" => last_week_time.strftime("%Y-%m-%d %H:%M:%S"),
              "user" => {
                "id" => other_user.id,
                "name" => other_user.name
              },
              "wakeup_at" => (last_week_time + 2.seconds).strftime("%Y-%m-%d %H:%M:%S")
            }
          ],
          "success" => true,
        }
      )
    end
  end

  describe "POST #record_sleep_at" do
    it "JSON body response contains expected sleep_at" do
      post :record_sleep_at, params: { id: user.id }
      json_response = JSON.parse(response.body)
      operation_history = user.operation_histories.last

      expect(json_response).to eq(
        {
          "data" => {
            "created_at" => formated_now,
            "length_of_sleep" => nil,
            "id" => operation_history.id,
            "sleep_at" => formated_now,
            "user" => {
              "id" => user.id,
              "name" => user.name
            },
            "wakeup_at" => nil
          },
          "success" => true,
        }
      )
    end
  end

  describe "POST #record_wakeup_at" do
    it "JSON body response contains expected wakeup_at" do
      allow(Time).to receive(:current).and_return(two_seconds_later)
      post :record_wakeup_at, params: { id: user.id, operation_history_id: operation_history.id }
      json_response = JSON.parse(response.body)
      operation_history = user.operation_histories.last

      expect(json_response).to eq(
        {
          "data" => {
            "created_at" => now.strftime("%Y-%m-%d %H:%M:%S"),
            "length_of_sleep" => 2,
            "id" => operation_history.id,
            "sleep_at" => now.strftime("%Y-%m-%d %H:%M:%S"),
            "user" => {
              "id" => user.id,
              "name" => user.name
            },
            "wakeup_at" => two_seconds_later.strftime("%Y-%m-%d %H:%M:%S")
          },
          "success" => true,
        }
      )
    end
  end

  describe "POST #follow" do
    it "User has followed other_user already" do
      relationship
      post :follow, params: { id: user.id, other_user_id: other_user.id }
      json_response = JSON.parse(response.body)

      expect(json_response).to eq(
        { "errors" => { "followed_id" => ["has already been taken"] }, "success" => false}
      )
    end

    it "JSON body response contains expected last_relationship" do
      post :follow, params: { id: user.id, other_user_id: other_user.id }
      last_relationship = user.relationships.last
      json_response = JSON.parse(response.body)

      expect(json_response).to eq(
        {
          "data" => {
            "followed" => {
              "id" => other_user.id,
              "name" => other_user.name
            },
            "follower" => {
              "id" => user.id,
              "name" => user.name
            },
            "id" => last_relationship.id
          },
          "success" => true,
        }
      )
    end
  end

  describe "POST #unfollow" do
    it "User has unfollowed other_user already or didn't follow before" do
      post :unfollow, params: { id: user.id, other_user_id: other_user.id }
      json_response = JSON.parse(response.body)

      expect(json_response).to eq(
        { "errors" => "you have unfollowed already or didn't follow before", "success" => false }
      )
    end

    it "JSON body response contains success json" do
      relationship
      post :unfollow, params: { id: user.id, other_user_id: other_user.id }
      json_response = JSON.parse(response.body)

      expect(json_response).to eq({ "success" => true })
    end
  end
end
