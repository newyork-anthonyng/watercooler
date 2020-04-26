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
            emails = params[:emails]
            errors = []
            emails.each do |email|
                existing_user = User.where(:email => email)
                if existing_user.present?
                    errors.push "#{email} user already exists."
                else
                    user = User.create(
                        email: email,
                        first_name: "Nathaneal",
                        last_name: "Down",
                        phone_number: "555-555-5555",
                        team: team,
                        password: "password123"
                    )
                end
            end

            render json: { errors: errors }, :status => :created
        rescue
            render json: {}, :status => :unprocessable_entity
        end
    end

    def applesauce
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