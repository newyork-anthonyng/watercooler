class ApplicationController < ActionController::Base
    skip_forgery_protection
    before_action :require_login

    def authorized_user
        return false if current_user.nil?

        current_user.is_admin
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
end
