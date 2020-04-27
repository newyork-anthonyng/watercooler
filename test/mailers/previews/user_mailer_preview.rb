# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
    def team_created_verification_email
        UserMailer.with(user: User.last).team_created_verification_email
    end
end
