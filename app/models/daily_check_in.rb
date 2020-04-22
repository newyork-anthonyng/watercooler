class DailyCheckIn < ApplicationRecord
    validates :doing_today, presence: true
    validates :mood, inclusion: { in: ["😀", "🙂", "🙁"] }

    belongs_to :user
end
