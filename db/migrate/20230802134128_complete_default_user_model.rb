class CompleteDefaultUserModel < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.string :username, null: false
      t.references :company, null: false
      t.uuid :uuid, default: 'gen_random_uuid()', null: false, index: { unique: true }
    end
  end
end
