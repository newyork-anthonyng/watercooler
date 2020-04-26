class Team < ApplicationRecord
    has_many :users, dependent: :destroy

    validates :name, presence: true, uniqueness: true
end
