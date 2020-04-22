require 'test_helper'

class DailyCheckInControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = Team.create(name: "Watercooler")
    @user = User.create(
      :first_name => "John",
      :last_name => "Doe",
      :email => "johndoe@example.com",
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

  test "should create check-in" do
    login_as @user.email, @user.password
    post daily_check_in_url, as: :json, params: {
      check_in: {
        doing_today: "Call dad",
        done_yesterday: "Call mom",
        mood: "😀"
      }
    }

    new_check_in = DailyCheckIn.where(:user => @user).first
    assert_equal true, new_check_in.present?
    assert_equal "Call dad", new_check_in.doing_today
    assert_equal "Call mom", new_check_in.done_yesterday
    assert_equal "😀", new_check_in.mood
    assert_response :created
  end

  test "should return error if not logged in" do
    post daily_check_in_url, as: :json, params: {
      check_in: {
        doing_today: "Call dad",
        done_yesterday: "Call mom",
        mood: "😀"
      }
    }

    new_check_in = DailyCheckIn.where(:user => @user).first
    assert_equal false, new_check_in.present?
    assert_response :unauthorized
  end

  test "should return error for invalid moods" do
    login_as @user.email, @user.password
    post daily_check_in_url, as: :json, params: {
      check_in: {
        doing_today: "Call dad",
        done_yesterday: "Call mom",
        mood: "💩"
      }
    }

    new_check_in = DailyCheckIn.where(:user => @user).first
    assert_equal false, new_check_in.present?
    assert_response :unprocessable_entity
  end
end
