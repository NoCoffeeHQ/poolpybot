class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto'
    create_table :companies do |t|
      t.string :name, null: false
      t.uuid :uuid, default: 'gen_random_uuid()', null: false, index: { unique: true }

      t.timestamps
    end
  end
end
