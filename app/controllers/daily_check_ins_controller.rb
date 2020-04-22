class DailyCheckInsController < ApplicationController
    def check_in
        daily_check_in = DailyCheckIn.new(check_in_params)
        daily_check_in.user = current_user

        if daily_check_in.valid?
            daily_check_in.save

            render json: {}, :status => :created
        else
            render json: { :check_in => daily_check_in.errors },
                :status => :unprocessable_entity
        end
    end

    private
        def check_in_params
            params.require(:check_in).permit(
                :doing_today,
                :done_yesterday,
                :mood
            )
        end
end
