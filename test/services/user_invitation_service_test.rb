require "test_helper"

class UserInvitationServiceTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "invites a user to any role, assigns the role, and emails the invitation" do
    user = users(:two)
    role = roles(:one)

    invitation = nil
    assert_difference -> { RoleAssignment.active.where(user: user, role: role).count } => 1 do
      assert_enqueued_email_with InvitationsMailer, :invite, args: ->(args) { invitation = args.first } do
        UserInvitationService.new(user: user, role: role, invited_by: users(:one)).call
      end
    end

    assert_equal user, invitation.user
    assert_equal role, invitation.role
    assert_equal users(:one), invitation.invited_by
    assert_nil invitation.accepted_at
  end

  test "does not duplicate an existing active role assignment" do
    user = users(:pending_owner)

    assert_no_difference -> { RoleAssignment.count } do
      UserInvitationService.new(user: user, role: roles(:pending_owner), invited_by: users(:admin)).call
    end
    assert_equal 1, user.invitations.count
  end
end
