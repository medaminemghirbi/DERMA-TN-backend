class WeeksController < ApplicationController
  def index
    doctor_id = params[:doctor_id]
    doctor = Doctor.find_by(id: doctor_id)
    year = params[:year] || Date.current.year
    days = get_days_of_year(year.to_i, doctor)
    render json: days
  end

  private

  def get_days_of_year(year, doctor)
    # Start from today
    today = Date.current
    first_day_of_year = Date.new(year, 1, 1)
    last_day_of_year = Date.new(year, 12, 31)

    # Ensure we only generate dates starting from today
    first_day = [today, first_day_of_year].max

    # Find the first Monday after or on the first day
    first_monday = first_day
    first_monday += 1 while first_monday.cwday != 1

    days = []
    current_date = first_monday

    while current_date <= last_day_of_year
      # Skip Sundays (day == 7(dimanche))
      if current_date.cwday != 7
        if current_date.cwday == 6
          days << { day: current_date.strftime("%A"), date: current_date.to_s } if doctor&.working_saturday
        else
          days << { day: current_date.strftime("%A"), date: current_date.to_s }
        end
      end
      current_date += 1
    end

    days
  end
end
