class UsersController < ApplicationController
    skip_before_action :require_login, only: [:verify]

    def verify 
        invitation_hash = params[:invitation_hash]
        user = User.find_by(:invitation_hash => invitation_hash)

        if user.present?
            user.update(:invite_status => "active", :invitation_hash => nil)

            render json: {}, :status => :ok
        else
            render json: {}, :status => :not_found
        end
    end

    def index
        return render json: {}, :status => :unauthorized if !authorized_user

        my_team = current_user.team
        team_users = my_team.users.pluck(:email)

        render json: { users: team_users }, :status => :ok
    end
end
