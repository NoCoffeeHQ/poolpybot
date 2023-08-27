class UserInvitation < ApplicationRecord
  ## associations ##
  belongs_to :company
  belongs_to :invited_by, class_name: 'User', foreign_key: 'user_id'

  ## validations ##
  validates :email, email: true, presence: true, uniqueness: { scope: :company_id }
  validate :cant_create_if_already_a_workmate
  validate :cant_create_if_guest_has_invoices

  ## scopes ##
  scope :by_token, ->(token) { where(UserInvitation[:token].eq(token).and(UserInvitation[:expired_at].gteq(Time.zone.now))) }
  scope :by_email, ->(email) { joins(:invited_by, :company).where(email: email) }

  ## methods ##

  def accept!(user)
    user.company = company
    user.save!
    destroy
  end
  
  ## class methods ##

  def self.invite(email:, invited_by:)
    # use cases:
    # the email doesn't belong to an existing user: -> Redirect to the sign up page + invitation token
    # the email belongs to an existing user:
    # - if the user has invoices -> display an error message
    # - if the user is already part of the company -> display an error message
    # - if the user has no invoices, send the invitation + display a notification in the settings page
    invitation = create(company: invited_by.company, invited_by: invited_by, email: email, expired_at: 1.day.from_now)
    
    if invitation.errors.blank?
      UserMailer.send_invitation(invitation.reload, User.exists?(email: email)).deliver_later
    end
    
    invitation
  end

  ## private methods ##

  private 
  
  def cant_create_if_already_a_workmate
    if company.users.exists?(email: email)
      errors.add(:email, :already_a_workmate)
    end
  end

  def cant_create_if_guest_has_invoices
    guest = User.where(email: email).where.not(company_id: company.id).first
    if guest && guest.invoices.count > 0
      errors.add(:email, :already_active_elsewhere)
    end
  end
end

# == Schema Information
#
# Table name: user_invitations
#
#  id         :bigint           not null, primary key
#  email      :string
#  expired_at :datetime         not null
#  token      :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_company_user_invitation_uniqueness  (company_id,email) UNIQUE
#  index_user_invitations_on_company_id      (company_id)
#  index_user_invitations_on_token           (token) UNIQUE
#  index_user_invitations_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (user_id => users.id)
#
