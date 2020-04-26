require 'test_helper'

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = Team.create(name: "Watercooler")
    @user = User.create(
      :first_name => "John",
      :last_name => "Doe",
      :email => "johndoe@example.com",
      :phone_number => "555-555-5555",
      :password => "a1b2c3",
      :team => @team,
      :is_admin => true
    )
  end

  def login_as(email, password)
    post login_url, as: :json, params: {
      email: email,
      password: password
    }
  end

  test "should create team with admin user" do
    post teams_url, as: :json, params: {
        team: { name: "Watercooler1" },
        user: {
            first_name: "Jane",
            last_name: "Doe",
            email: "janedoe@example.com",
            phone_number: "555-555-5555",
            password: "a1b2c3"
        }
    }

    new_user = User.where(email: "janedoe@example.com").first
    new_team = Team.where(name: "Watercooler1").first

    assert_equal(true, new_user.is_admin)
    assert_equal(true, new_user.present?)
    assert_equal(true, new_team.present?)
    assert_response :created
  end

  test "should cleanup team and user if error" do
    invalid_user = {
        last_name: "Doe",
        email: "janedoe@example.com",
        password: "a1b2c3"
    }
    post teams_url, as: :json, params: {
        team: { name: "Watercooler1" },
        user: invalid_user
    }

    new_user = User.where(email: "janedoe@example.com").first
    new_team = Team.where(name: "Watercooler1").first

    assert_equal(false, new_user.present?)
    assert_equal(false, new_user.present?)
    assert_response :unprocessable_entity
  end

  test "should return error if team with name already exists" do
    post teams_url, as: :json, params: {
        team: { name: "Watercooler" },
        user: {
            first_name: "Jane",
            last_name: "Doe",
            email: "janedoe@example.com",
            phone_number: "555-555-5555",
            password: "a1b2c3"
        }
    }

    assert_response :unprocessable_entity
  end

  test "should create dummy users when inviting members to team" do
    login_as @user.email, @user.password

    post "/teams/invite", as: :json, params: {
      emails: ["a@gmail.com", "b@gmail.com"]
    }

    first_user = User.where(:email => "a@gmail.com").first
    second_user = User.where(:email => "b@gmail.com").first
    assert_equal(true, first_user.present?)
    assert_equal(true, first_user.invited?)
    assert_equal(true, second_user.present?)
    assert_equal(true, second_user.invited?)
    assert_response :created
  end

  test "should return errors if email already exists" do
    login_as @user.email, @user.password

    post "/teams/invite", as: :json, params: {
      emails: [@user.email]
    }

    assert_response :created
    assert_equal(["#{@user.email} user already exists."], JSON.parse(response.body)["errors"])
  end

  test "should return error if not logged in" do
    post "/teams/invite", as: :json, params: {
      emails: ["a@gmail.com", "b@gmail.com"]
    }

    first_user = User.where(:email => "a@gmail.com").first
    second_user = User.where(:email => "b@gmail.com").first
    assert_equal(false, first_user.present?)
    assert_equal(false, second_user.present?)
    assert_response :unauthorized
  end

  test "should add new user to team" do
    login_as @user.email, @user.password

    post "/teams/#{@team.id}/applesauce", as: :json, params: {
        user: {
            first_name: "Jane",
            last_name: "Doe",
            email: "janedoe@example.com",
            phone_number: "555-555-5555",
            password: "a1b2c3"
        }
    }

    new_user = User.where(:email => "janedoe@example.com").first
    assert_equal(true, new_user.present?)
    assert_response :created
  end

  test "should return error if team is not found" do
    login_as @user.email, @user.password
    non_existent_team = 123456

    post "/teams/#{non_existent_team}/applesauce", as: :json, params: {
        user: {
            first_name: "Jane",
            last_name: "Doe",
            email: "janedoe@example.com",
            password: "a1b2c3"
        }
    }

    new_user = User.where(:email => "janedoe@example.com").first
    assert_equal(false, new_user.present?)
    assert_response :not_found
  end

  test "should return error if invitation is for different team" do
    login_as @user.email, @user.password
    another_team = Team.create(name: "Another team")

    post "/teams/#{another_team.id}/applesauce", as: :json, params: {
        user: {
            first_name: "Jane",
            last_name: "Doe",
            email: "janedoe@example.com",
            password: "a1b2c3"
        }
    }

    new_user = User.where(:email => "janedoe@example.com").first
    assert_equal(false, new_user.present?)
    assert_response :unauthorized
  end

  test "should return error if user is invalid" do
    login_as @user.email, @user.password

    invalid_user = {
        last_name: "Doe",
        email: "janedoe@example.com",
        password: "a1b2c3"
    }
    post "/teams/#{@team.id}/applesauce", as: :json, params: {
        user: invalid_user
    }

    new_user = User.where(:email => "janedoe@example.com").first
    assert_equal(false, new_user.present?)
    assert_response :unprocessable_entity
  end

  test "should return error if invitee is not an admin" do
    @user.update(:is_admin => false)

    login_as @user.email, @user.password
    post "/teams/#{@team.id}/applesauce", as: :json, params: {
        user: {
            first_name: "Jane",
            last_name: "Doe",
            email: "janedoe@example.com",
            password: "a1b2c3"
        }
    }

    new_user = User.where(:email => "janedoe@example.com").first
    assert_equal(false, new_user.present?)
    assert_response :unauthorized
  end
end
