class CreateUserInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :user_invitations do |t|
      t.references :company, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.uuid :token, default: 'gen_random_uuid()', null: false, index: { unique: true }
      t.datetime :expired_at, null: false
      t.string :email
      
      t.timestamps

      t.index [:company_id, :email], name: 'index_company_user_invitation_uniqueness', unique: true
    end
  end
end
