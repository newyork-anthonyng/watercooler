class UsersController < ApplicationController
    skip_before_action :require_login, only: [:verify, :additionalInformation]

    def verify 
        invitation_hash = params[:invitation_hash]
        user = User.find_by(:invitation_hash => invitation_hash)

        if user.present?
            if user.is_admin
                user.update(:invite_status => "active", :invitation_hash => nil)

                render json: {}, :status => :ok
            else
                render json: { data: { email: user.email, team: user.team.name }}, :status => :ok
            end
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

    def additionalInformation
        begin
            user = User.where(:email => params[:user][:email]).first
            return render json: {}, :status => not_found if !user.present?

            if user.update(user_params)
                user.invitation_hash = nil
                user.invite_status = "active"
                user.save

                render json: {}, :status => :ok
            else
                render json: {}, :status => :unprocessable_entity
            end
        rescue
            render json: {}, :status => :unprocessable_entity
        end
    end

    private

        def user_params
            params.require(:user).permit(
                :first_name,
                :last_name,
                :email,
                :phone_number,
                :password, 
                :password_confirmation
            )
        end
end
