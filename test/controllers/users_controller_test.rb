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
      :invitation_hash => "another_invitation_hash",
      :is_admin => true
    )
  end

  def login_as(email, password)
    post login_url, as: :json, params: {
      email: email,
      password: password
    }
  end

  test "should return success if admin invitation hash is valid" do
    post "/verify/#{@admin.invitation_hash}", as: :json

    @admin.reload

    assert_equal(true, @admin.active?)
    assert_equal(true, @admin.invitation_hash.nil?)
    assert_response :ok
  end

  test "should return success if team invitation hash is valid" do
    post "/verify/#{@user.invitation_hash}", as: :json

    @user.reload

    assert_equal(false, @user.active?)
    assert_equal(false, @user.invitation_hash.nil?)

    parsed_response_body = JSON.parse response.body
    assert_equal(@user.email, parsed_response_body["data"]["email"])
    assert_equal(@team.name, parsed_response_body["data"]["team"])
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

  test "should update new user information" do
    user = User.create(
      :first_name => "Default",
      :last_name => "User",
      :email => "invited@gmail.com",
      :phone_number => "555-555-5555",
      :password => "a1b2c3",
      :team => @team
    )

    post "/verify-additional-information", as: :json, params: {
      user: {
          first_name: "Jane",
          last_name: "Doe",
          email: "invited@gmail.com",
          phone_number: "123-456-7890",
          password: "a1b2c3",
          password_confirmation: "a1b2c3"
      }
    }

    user.reload
    assert_equal("Jane", user.first_name)
    assert_equal("Doe", user.last_name)
    assert_equal("123-456-7890", user.phone_number)
    assert_equal(nil, user.invitation_hash)
    assert_equal(true, user.active?)
  end
end
