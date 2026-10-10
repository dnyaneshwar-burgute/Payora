require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  setup do
    @params = {
      organization: {
        name: "Globex",
        host: " Globex.Example.com ",
        users_attributes: {
          "0" => {
            first_name: "Jane",
            last_name: "Doe",
            email_address: "jane@globex.test",
            phone_number: ""
          }
        }
      }
    }
  end

  test "renders the nested registration form" do
    get new_registration_path
    assert_response :success
    assert_select "form[action=?]", registration_path
    assert_select "input[name=?]", "organization[name]"
    assert_select "input[name=?]", "organization[users_attributes][0][email_address]"
    assert_select "input[type=password]", count: 0
  end

  test "registers an organization and makes the user its owner" do
    assert_difference -> { Organization.count } => 1, -> { User.count } => 1, -> { Role.count } => 1, -> { RoleAssignment.count } => 1 do
      post registration_path, params: @params
    end

    assert_redirected_to root_path
    assert cookies[:session_id].present?

    organization = Organization.last
    assert_equal "globex.example.com", organization.host
    assert_equal "active", organization.status

    owner = organization.users.sole
    assignment = RoleAssignment.find_by!(user: owner)
    assert assignment.role.organization_owner?
    assert_equal organization, assignment.role.organization
    assert_equal owner, assignment.assigned_by
  end

  test "shows nested errors and creates nothing when invalid" do
    @params[:organization][:name] = ""
    @params[:organization][:users_attributes]["0"][:first_name] = ""

    assert_no_difference [ "Organization.count", "User.count", "Role.count" ] do
      post registration_path, params: @params
    end

    assert_response :unprocessable_entity
    assert_select ".invalid-feedback", text: /Name can't be blank/
    assert_select ".invalid-feedback", text: /First name can't be blank/
  end

  test "rejects a duplicate host" do
    post registration_path, params: @params
    delete session_path

    @params[:organization][:users_attributes]["0"][:email_address] = "other@globex.test"
    assert_no_difference -> { Organization.count } do
      post registration_path, params: @params
    end
    assert_select ".invalid-feedback", text: /Host has already been taken/
  end

  test "requires exactly one owner" do
    @params[:organization][:users_attributes]["1"] = @params[:organization][:users_attributes]["0"].merge(email_address: "second@globex.test")

    assert_no_difference -> { Organization.count } do
      post registration_path, params: @params
    end
    assert_select ".alert-danger", text: /Exactly one owner account is required/
  end

  test "signs the owner in after registration and out again" do
    post registration_path, params: @params
    follow_redirect!
    assert_select "button", text: "Sign out"

    delete session_path
    assert_redirected_to new_session_path
  end

  test "signs in with email and password" do
    post session_path, params: { email_address: users(:one).email_address, password: "password" }
    assert_redirected_to root_path

    follow_redirect!
    assert_select "button", text: "Sign out"
  end
end
