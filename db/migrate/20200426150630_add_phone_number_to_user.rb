class AddPhoneNumberToUser < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.column :phone_number, :string, :null => false, :default => "555-555-5555"
    end

    change_column_default :users, :phone_number, nil 
  end
end
