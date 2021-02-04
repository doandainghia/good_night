class CreateOperationHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :operation_histories do |t|
      t.references :user
      t.datetime :wakeup_at
      t.datetime :sleep_at
      t.datetime :created_at
      t.bigint :distance_time
    end
  end
end
