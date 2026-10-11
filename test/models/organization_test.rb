require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "starts in the created state" do
    assert Organization.new(name: "New", host: "new.example.com").created?
  end

  test "known hosts are permitted by host authorization" do
    permissions = ActionDispatch::HostAuthorization::Permissions.new([ ->(host) { Organization.known_host?(host) } ])

    assert Organization.known_host?("acme.example.com")
    assert Organization.known_host?("ACME.EXAMPLE.COM:3000")
    assert_not Organization.known_host?("missing.example.com")
    assert_not Organization.known_host?(nil)

    assert permissions.allows?("acme.example.com")
    assert permissions.allows?("acme.example.com:3000")
    assert_not permissions.allows?("missing.example.com")
  end

  test "approving invites the owners after commit" do
    organization = organizations(:pending)

    assert_difference -> { Invitation.count } => 1 do
      assert_enqueued_emails 1 do
        assert organization.approve!(users(:admin))
      end
    end

    assert organization.reload.approved?
    assert_equal users(:admin), Invitation.last.invited_by
  end

  test "rejects with a reason" do
    organization = organizations(:pending)
    organization.rejection_reason = "Incomplete details"

    assert_no_difference -> { Invitation.count } do
      assert organization.reject!
    end
    assert organization.reload.rejected?
    assert_equal "Incomplete details", organization.rejection_reason
  end

  test "requires a reason to reject" do
    organization = organizations(:pending)
    organization.rejection_reason = "  "

    assert_not organization.reject!
    assert_includes organization.errors[:rejection_reason], "can't be blank"
    assert organization.reload.created?
  end

  test "cannot be reviewed twice" do
    organization = organizations(:acme)

    assert_not organization.may_approve?
    assert_not organization.may_reject?
    assert_no_enqueued_emails do
      assert_raises(AASM::InvalidTransition) { organization.approve!(users(:admin)) }
    end
  end

  test "owners are users with an active owner role" do
    assert_equal [ users(:pending_owner) ], organizations(:pending).owners.to_a
  end
end
