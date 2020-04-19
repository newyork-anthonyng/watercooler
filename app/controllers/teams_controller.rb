class TeamsController < ApplicationController
    def create
        team = Team.new(team_params)
        user = User.new(user_params)
        user.is_admin = true
        user.team = team

        respond_to do |format|
            if team.valid? and user.valid?
                team.save
                user.save

                format.json {
                    render json: { :team => team, :user => user },
                    :status => :created
                }
            else
                format.json {
                    render json: { :team => team.errors, :user => user.errors },
                    :status => :unprocessable_entity
                }
            end
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
                :password, 
                :password_confirmation
            )
        end
end