require "test_helper"

class Tenant::DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! organizations(:acme).host
  end

  test "requires sign in" do
    get tenant_dashboard_path
    assert_redirected_to new_session_path
  end

  test "an owner signs in on the organization domain and lands on the dashboard" do
    sign_in_as users(:acme_owner)
    assert_redirected_to root_path

    follow_redirect!
    assert_response :success
    assert_select "h1", text: "Acme"
  end

  test "only counts records of the current organization" do
    sign_in_as users(:acme_owner)

    get tenant_dashboard_path
    assert_select ".card-body", text: /Users\s+3/
    assert_select ".card-body", text: /Departments\s+2/
    assert_select ".card-body", text: /Roles\s+3/
  end

  test "users of another organization cannot sign in on this domain" do
    sign_in_as users(:admin)

    assert_redirected_to new_session_path
    assert_equal "Try another email address or password.", flash[:alert]
    assert cookies[:session_id].blank?
  end

  test "is available to members who are not owners" do
    sign_in_as users(:one)

    get tenant_dashboard_path
    assert_response :success
  end

  test "is forbidden for platform admins on their organization domain" do
    host! organizations(:platform).host
    sign_in_as users(:admin)

    get tenant_dashboard_path
    assert_response :forbidden
  end

  test "platform routes are not available on an organization domain" do
    sign_in_as users(:acme_owner)

    get "/admin/organizations"
    assert_response :not_found

    get "/registration/new"
    assert_response :not_found
  end

  test "the dashboard is not available on the platform domain" do
    host! "www.example.com"

    get "/dashboard"
    assert_response :not_found
  end

  private
    def sign_in_as(user)
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
end
