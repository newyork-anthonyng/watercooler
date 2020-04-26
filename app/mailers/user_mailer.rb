class UserMailer < ApplicationMailer
    default from: "notifications@example.com"

    def team_created_verification_email
        @user = params[:user]
        @url = "http://localhost:8080/login"
        mail(to: @user.email, subject: "Welcome to My Awesome Site")
    end
end
