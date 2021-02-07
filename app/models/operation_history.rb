class OperationHistory < ApplicationRecord
  belongs_to :user

  scope :newest, -> { order created_at: :desc }
  scope :last_week, -> do
    begin_time = Date.current.beginning_of_week.last_week.beginning_of_day
    end_time = Date.today.at_end_of_week.last_week(:sunday).end_of_day
    range_time = begin_time..end_time

    where(wakeup_at: range_time, sleep_at: range_time)
  end
  scope :order_by_length_of_sleep, -> user_ids do
    select("*, TIMEDIFF(wakeup_at, sleep_at) as length_of_sleep")
    .where(user_id: user_ids)
    .order("length_of_sleep DESC")
  end

  validates :sleep_at, presence: true
  validates :wakeup_at, presence: true, on: :update
end
