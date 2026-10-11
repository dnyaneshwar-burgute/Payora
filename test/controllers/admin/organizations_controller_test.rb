require "test_helper"

class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @organization = organizations(:pending)
  end

  test "requires sign in" do
    get admin_organizations_path
    assert_redirected_to new_session_path

    get admin_organizations_path, as: :json
    assert_response :unauthorized
  end

  test "is forbidden for non platform admins" do
    sign_in_as users(:one)

    get admin_organizations_path
    assert_redirected_to root_path

    get admin_organizations_path, as: :json
    assert_response :forbidden

    patch change_state_admin_organization_path(@organization), params: { event: "approve" }, as: :json
    assert_response :forbidden
    assert @organization.reload.created?
  end

  test "renders the review app and lists organizations as json" do
    sign_in_as users(:admin)

    get admin_organizations_path
    assert_response :success
    assert_select "#root"

    get admin_organization_path(@organization)
    assert_response :success
    assert_select "#root"

    get admin_organizations_path(status: "created"), as: :json
    assert_response :success
    names = response.parsed_body["organizations"].pluck("name")
    assert_includes names, "Pending Co"
    assert_not_includes names, "Acme"
  end

  test "shows an organization" do
    sign_in_as users(:admin)

    get admin_organization_path(@organization), as: :json

    assert_response :success
    organization = response.parsed_body["organization"]
    assert_equal "Pending Co", organization["name"]
    assert_equal "pending.example.com", organization["host"]
    assert_equal "created", organization["status"]
    assert_equal "Pending Owner", organization.dig("owners", 0, "full_name")
    assert_equal "owner@pending.example.com", organization.dig("owners", 0, "email_address")
  end

  test "approves an organization and emails the owner" do
    sign_in_as users(:admin)

    assert_difference -> { Invitation.count } => 1 do
      assert_enqueued_emails 1 do
        patch change_state_admin_organization_path(@organization), params: { event: "approve" }, as: :json
      end
    end

    assert_response :success
    body = response.parsed_body
    assert_equal "approved", body.dig("organization", "status")
    assert_match "approved", body["notice"]
    assert_match "invitation", body["notice"]
    assert @organization.reload.approved?

    invitation = Invitation.last
    assert_equal users(:pending_owner), invitation.user
    assert_equal roles(:pending_owner), invitation.role
    assert_equal users(:admin), invitation.invited_by
  end

  test "rejects an organization with a reason" do
    sign_in_as users(:admin)

    assert_no_enqueued_emails do
      patch change_state_admin_organization_path(@organization), params: { event: "reject", rejection_reason: "Not a real company" }, as: :json
    end

    assert_response :success
    body = response.parsed_body
    assert_equal "rejected", body.dig("organization", "status")
    assert_equal "Not a real company", body.dig("organization", "rejection_reason")
    assert_match "rejected", body["notice"]
    assert @organization.reload.rejected?
    assert_equal "Not a real company", @organization.rejection_reason
  end

  test "requires a reason to reject" do
    sign_in_as users(:admin)

    patch change_state_admin_organization_path(@organization), params: { event: "reject", rejection_reason: "" }, as: :json

    assert_response :unprocessable_entity
    assert_includes response.parsed_body.dig("field_errors", "rejection_reason"), "Rejection reason can't be blank"
    assert @organization.reload.created?
  end

  test "refuses unknown events" do
    sign_in_as users(:admin)

    patch change_state_admin_organization_path(@organization), params: { event: "destroy" }, as: :json

    assert_response :unprocessable_entity
    assert_equal "Unknown review action.", response.parsed_body["error"]
    assert @organization.reload.created?
  end

  test "refuses to review an organization twice" do
    sign_in_as users(:admin)

    assert_no_enqueued_emails do
      patch change_state_admin_organization_path(organizations(:acme)), params: { event: "approve" }, as: :json
    end

    assert_response :unprocessable_entity
    assert_match "already been reviewed", response.parsed_body["error"]
  end

  private
    def sign_in_as(user)
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
end
