class AddInvitedStatusToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :invite_status, :integer, :default => 0
  end
end
