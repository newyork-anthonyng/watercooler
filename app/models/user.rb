class User < ApplicationRecord
    has_secure_password

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true, uniqueness: true

    belongs_to :team

    has_many :daily_check_ins, dependent: :destroy

    enum invite_status: [:invited, :active]
end
