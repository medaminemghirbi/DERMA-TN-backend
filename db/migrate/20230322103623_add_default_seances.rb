class AddDefaultSeances < ActiveRecord::Migration[7.0]
  def up
    Seance.create([
      { start_time: "09:00", end_time: "09:30" },
      { start_time: "09:30", end_time: "10:00" },
      { start_time: "10:00", end_time: "10:30" },
      { start_time: "10:30", end_time: "11:00" },
      { start_time: "11:00", end_time: "11:30" },
      { start_time: "11:30", end_time: "12:00" },
      { start_time: "12:00", end_time: "12:30" },
      { start_time: "13:30", end_time: "14:00" },
      { start_time: "14:00", end_time: "14:30" },
      { start_time: "14:30", end_time: "15:00" },
      { start_time: "15:00", end_time: "15:30" },
      { start_time: "15:30", end_time: "16:00" },
      { start_time: "16:00", end_time: "16:30" }
    ])
  end

  def down
    Seance.delete_all
  end
end
