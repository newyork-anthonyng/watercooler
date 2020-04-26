class TeamsController < ApplicationController
    skip_before_action :require_login, only: [:create]

    def create
        team = Team.new(team_params)
        user = User.new(user_params)
        user.is_admin = true
        user.team = team

        if team.valid? and user.valid?
            team.save
            user.save

            render json: { :team => team, :user => user },
            :status => :created
        else
            render json: { :team => team.errors, :user => user.errors },
                :status => :unprocessable_entity
        end
    end

    def invite
        begin
            team = Team.find(params[:id])
            if current_user.team != team or !authorized_user
                return render json: {}, :status => :unauthorized
            end

            user = User.new(user_params)
            user.team = team

            if user.valid?
                user.save

                render json: { :team => team, :user => user },
                    :status => :created
            else
                render json: { :team => team.errors, :user => user.errors },
                    :status => :unprocessable_entity
            end
        rescue
            render json: {}, :status => :not_found
        end
    end

    private
        def team_params
            params.require(:team).permit(:name)
        end

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