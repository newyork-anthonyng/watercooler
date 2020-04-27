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
end
