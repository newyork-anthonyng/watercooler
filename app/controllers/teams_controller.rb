class TeamsController < ApplicationController
    skip_before_action :require_login, only: [:create, :additionalInformation]

    def create
        team = Team.new(team_params)
        user = User.new(user_params)
        user.is_admin = true
        user.team = team

        if team.valid? and user.valid?
            user.invitation_hash = encrypt ("#{user.first_name}, #{user.last_name}, #{user.email}")

            team.save
            user.save

            UserMailer.with(user: user).team_created_verification_email.deliver_later

            render json: { :team => team, :user => user },
            :status => :created
        else
            render json: { :team => team.errors, :user => user.errors },
                :status => :unprocessable_entity
        end
    end

    def invite
        begin
            emails = params[:emails]
            errors = []
            emails.each do |email|
                existing_user = User.where(:email => email)
                if existing_user.present?
                    errors.push "#{email} user already exists."
                else
                    invitation_hash = encrypt ("Nathaneal, Down, #{email}")
                    user = User.create(
                        email: email,
                        first_name: "Nathaneal",
                        last_name: "Down",
                        phone_number: "555-555-5555",
                        team: current_user.team,
                        password: "password123",
                        invitation_hash: invitation_hash
                    )

                    if user.persisted?
                        UserMailer.with(user: user).team_member_invite_email.deliver_later
                    end
                end
            end

            render json: { errors: errors }, :status => :created
        rescue
            render json: {}, :status => :unprocessable_entity
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
