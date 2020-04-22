class SessionsController < ApplicationController
    skip_before_action :require_login

    def create
        user = User.find_by_email(params[:email])

        if user and user.authenticate(params[:password])
            session[:user_id] = user.id
            render json: {}, :status => :created
        else
            render json: {}, :status => :unauthorized
        end
    end

    def destroy
        session[:user_id] = nil
        render json: {}, :status => :ok
    end
end