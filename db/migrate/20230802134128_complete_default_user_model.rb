class CompleteDefaultUserModel < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.string :username, null: false
      t.references :company, null: false
    end
  end
end
