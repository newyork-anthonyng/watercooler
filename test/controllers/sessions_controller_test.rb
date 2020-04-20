require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
        team = Team.create(:name => "Watercooler")
        @user = User.create(
            :first_name => "John",
            :last_name => "Doe",
            :email => "johndoe@example.com",
            :password => "a1b2c3",
            :team => team
        )
    end

    test "should login correctly" do
        post login_url, as: :json, params: {
            email: "johndoe@example.com",
            password: "a1b2c3"
        }

        assert_response :created
        assert_equal @user.id, session[:user_id]
    end

    test "should return error when login fails" do
        post login_url, as: :json, params: {
            email: "johndoe@example.com",
            password: "wrong_password"
        }

        assert_response :unauthorized
        assert_nil session[:user_id]
    end

    test "should logout correctly" do
        post login_url, as: :json, params: {
            email: "johndoe@example.com",
            password: "a1b2c3"
        }

        assert_response :created
        assert_equal @user.id, session[:user_id]

        post logout_url, as: :json

        assert_response :ok
        assert_nil session[:user_id]
    end
end