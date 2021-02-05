# README

## Run good_night project:
- clone project: git clone https://github.com/doandainghia/good_night
- go into project after clone: cd good_night
- install libraries command: bundle install
- init database command: rails db:setup
- after init datdabase. There are 10 user records was created.
- run server command: rails s
- run test command: rspec

## API list:
- GET /api/v1/users/:user_id/operation_histories
- GET /api/v1/users/:user_id/operation_history_of_friends
- POST /api/v1/users/:user_id/record_sleep_at
- POST /api/v1/users/:user_id/record_wakeup_at, params: { operation_history_id: integer }
- POST /api/v1/users/:user_id/follow, params: { other_user_id: integer }
- POST /api/v1/users/:user_id/unfollow, params: { other_user_id: integer }
