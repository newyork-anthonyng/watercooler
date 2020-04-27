class AddInvitationLinkToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :invitation_hash, :string
  end
end
