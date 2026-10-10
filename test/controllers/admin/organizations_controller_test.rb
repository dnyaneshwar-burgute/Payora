require "test_helper"

class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @organization = organizations(:pending)
  end

  test "requires sign in" do
    get admin_organizations_path
    assert_redirected_to new_session_path
  end

  test "is forbidden for non platform admins" do
    sign_in_as users(:one)

    get admin_organizations_path
    assert_redirected_to root_path

    patch change_state_admin_organization_path(@organization), params: { event: "approve" }
    assert_redirected_to root_path
    assert @organization.reload.created?
  end

  test "lists and filters organizations" do
    sign_in_as users(:admin)

    get admin_organizations_path(status: "created")
    assert_response :success
    assert_select "td", text: "Pending Co"
    assert_select "td", text: "Acme", count: 0
  end

  test "approves an organization and emails the owner" do
    sign_in_as users(:admin)

    assert_difference -> { Invitation.count } => 1 do
      assert_enqueued_emails 1 do
        patch change_state_admin_organization_path(@organization), params: { event: "approve" }
      end
    end

    assert_redirected_to admin_organization_path(@organization)
    assert @organization.reload.approved?

    invitation = Invitation.last
    assert_equal users(:pending_owner), invitation.user
    assert_equal roles(:pending_owner), invitation.role
    assert_equal users(:admin), invitation.invited_by
  end

  test "rejects an organization with a reason" do
    sign_in_as users(:admin)

    assert_no_enqueued_emails do
      patch change_state_admin_organization_path(@organization), params: { event: "reject", rejection_reason: "Not a real company" }
    end

    assert_redirected_to admin_organization_path(@organization)
    assert @organization.reload.rejected?
    assert_equal "Not a real company", @organization.rejection_reason
  end

  test "requires a reason to reject" do
    sign_in_as users(:admin)

    patch change_state_admin_organization_path(@organization), params: { event: "reject", rejection_reason: "" }

    assert_response :unprocessable_entity
    assert_select ".invalid-feedback", text: /Rejection reason can't be blank/
    assert @organization.reload.created?
  end

  test "refuses unknown events" do
    sign_in_as users(:admin)

    patch change_state_admin_organization_path(@organization), params: { event: "destroy" }

    assert_response :unprocessable_entity
    assert_select ".alert-danger", text: /Unknown review action/
    assert @organization.reload.created?
  end

  test "refuses to review an organization twice" do
    sign_in_as users(:admin)

    assert_no_enqueued_emails do
      patch change_state_admin_organization_path(organizations(:acme)), params: { event: "approve" }
    end

    assert_response :unprocessable_entity
    assert_select ".alert-danger", text: /already been reviewed/
  end

  private
    def sign_in_as(user)
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
end
