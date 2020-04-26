# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
    def team_created_verification_email
        UserMailer.team_created_verification_email(User.last)
    end
end
