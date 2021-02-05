class OperationHistory < ApplicationRecord
  belongs_to :user

  scope :newest, -> { order created_at: :desc }
  scope :by_user_ids, -> user_ids { where user_id: user_ids }
  scope :last_week, -> do
    begin_time = Date.current.beginning_of_week.last_week.beginning_of_day
    end_time = Date.today.at_end_of_week.last_week(:sunday).end_of_day
    range_time = begin_time..end_time

    where(wakeup_at: range_time, sleep_at: range_time)
  end

  validates :sleep_at, presence: true
  validates :wakeup_at, presence: true, on: :update

  before_save :init_distance_time

  private

  def init_distance_time
    return unless wakeup_at
    self.distance_time = wakeup_at - sleep_at
  end
end
