class Invitation < ApplicationRecord
  EXPIRES_IN = 7.days

  scoped_to_organization through: :user

  belongs_to :user
  belongs_to :role
  belongs_to :invited_by, class_name: "User"

  generates_token_for :acceptance, expires_in: EXPIRES_IN do
    accepted_at
  end

  scope :pending, -> { where(accepted_at: nil) }

  def accept(password:, password_confirmation:)
    if password.blank?
      user.errors.add(:password, :blank)
      return false
    end

    transaction do
      user.update!(password: password, password_confirmation: password_confirmation)
      update!(accepted_at: Time.current)
      user.invitations.pending.where.not(id: id).update_all(accepted_at: accepted_at)
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end
end
