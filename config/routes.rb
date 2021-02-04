Rails.application.routes.draw do
  namespace :api, format: 'json' do
    namespace :v1 do
      resources :operation_histories, only: :create
      resources :users do
        member do
          post :follow, :unfollow, :record_sleep_at, :record_wakeup_at
          get :operation_histories, :operation_history_of_friends
        end
      end
    end
  end
end
