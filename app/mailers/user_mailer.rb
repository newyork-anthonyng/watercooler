class UserMailer < ApplicationMailer
    default from: "notifications@example.com"

    def team_created_verification_email
        @user = params[:user]
        encoded_hash = URI.encode_www_form_component(@user.invitation_hash)
        @url = "http://localhost:8080/verify/#{encoded_hash}"
        mail(to: @user.email, subject: "Thanks for joining us!")
    end

    def team_member_invite_email
        @user = params[:user]
        encoded_hash = URI.encode_www_form_component(@user.invitation_hash)
        @url = "http://localhost:8080/verify/#{encoded_hash}"
        mail(to: @user.email, subject: "You've been invited!")
    end
end
