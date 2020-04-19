require 'test_helper'

class TeamsControllerTest < ActionDispatch::IntegrationTest
  test "should create team with admin user" do
    assert_equal(0, Team.count)
    assert_equal(0, User.count)

    post teams_url, as: :json, params: {
        team: { name: "Watercooler" },
        user: {
            first_name: "John",
            last_name: "Doe",
            email: "johndoe@example.com",
            password: "a1b2c3"
        }
    }

    user = User.last
    assert_equal(true, user.is_admin)
    assert_equal(1, Team.count)
    assert_equal(1, User.count)
    assert_response :created
  end

  test "should cleanup team and user if error" do
    assert_equal(0, Team.count)
    assert_equal(0, User.count)

    invalid_user = {
        last_name: "Doe",
        email: "johndoe@example.com",
        password: "a1b2c3"
    }
    post teams_url, as: :json, params: {
        team: { name: "Watercooler" },
        user: invalid_user
    }

    assert_equal(0, Team.count)
    assert_equal(0, User.count)
    assert_response :unprocessable_entity
  end
end