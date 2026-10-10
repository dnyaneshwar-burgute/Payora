class UserInvitationService
  attr_reader :user, :role, :invited_by

  def initialize(user:, role:, invited_by:)
    @user = user
    @role = role
    @invited_by = invited_by
  end

  def call
    invitation = ActiveRecord::Base.transaction do
      unless user.role_assignments.active.exists?(role: role)
        RoleAssignment.create!(user: user, role: role, assigned_by: invited_by, effective_from: Time.current)
      end

      Invitation.create!(user: user, role: role, invited_by: invited_by)
    end

    InvitationsMailer.invite(invitation).deliver_later
    invitation
  end
end
