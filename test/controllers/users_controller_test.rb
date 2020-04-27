require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = Team.create(name: "Watercooler")
    @user = User.create(
      :first_name => "John",
      :last_name => "Doe",
      :email => "johndoe@example.com",
      :phone_number => "555-555-5555",
      :password => "a1b2c3",
      :team => @team,
      :invitation_hash => "some_invitation_hash"
    )
    @admin = User.create(
      :first_name => "Jane",
      :last_name => "Doe",
      :email => "janedoe@example.com",
      :phone_number => "555-555-5555",
      :password => "a1b2c3",
      :team => @team,
      :invitation_hash => "some_invitation_hash",
      :is_admin => true
    )
  end

  def login_as(email, password)
    post login_url, as: :json, params: {
      email: email,
      password: password
    }
  end

  test "should return success if invitation hash is valid" do
    post "/verify/some_invitation_hash", as: :json

    @user.reload

    assert_equal(true, @user.active?)
    assert_equal(true, @user.invitation_hash.nil?)
    assert_response :ok
  end

  test "should return error if invitation hash is not invalid" do
    post "/verify/invalid_invitation_hash", as: :json

    assert_response :not_found
  end

  test "should return error if user is not logged in" do
    get "/users", as: :json

    assert_response :unauthorized
  end

  test "should return error if user is not an admin" do
    login_as @user.email, @user.password
    get "/users", as: :json

    assert_response :unauthorized
  end

  test "should return list of users" do
    login_as @admin.email, @admin.password
    get "/users", as: :json

    parsed_response_body = JSON.parse response.body
    assert_response :ok
    assert_equal(["johndoe@example.com", "janedoe@example.com"], parsed_response_body["users"])
  end
end
