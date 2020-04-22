class CreateDailyCheckIns < ActiveRecord::Migration[6.0]
  def change
    create_table :daily_check_ins do |t|
      t.text :doing_today
      t.text :done_yesterday
      t.text :mood

      t.belongs_to :user, :null => false

      t.timestamps
    end
  end
end
