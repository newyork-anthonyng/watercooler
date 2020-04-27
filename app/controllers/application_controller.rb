class ApplicationController < ActionController::Base
    skip_forgery_protection
    before_action :require_login

    def authorized_user
        current_user && current_user.is_admin
    end

    def require_login
        if current_user.nil?
            render json: {}, :status => :unauthorized
        end
    end

    def current_user
        if session[:user_id]
            @current_user ||= User.find(session[:user_id])
        else
            @current_user = nil
        end
    end

    def crypt
        @crypt ||= ActiveSupport::MessageEncryptor.new(ENV["KEY"])
    end

    def encrypt(argument)
        # byebug
        crypt.encrypt_and_sign(argument)
    end

    def decrypt(argument)
        crypt.decrypt_and_verify(argument)
    end
end
