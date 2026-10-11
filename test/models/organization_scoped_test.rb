require "test_helper"

class OrganizationScopedTest < ActiveSupport::TestCase
  setup do
    @acme = organizations(:acme)
  end

  test "queries are unscoped without a current organization" do
    assert_includes User.all, users(:admin)
    assert_includes Role.all, roles(:platform_admin)
  end

  test "models with an organization are scoped to the current organization" do
    Current.set(organization: @acme) do
      assert_equal @acme.users.sort, User.all.sort
      assert_equal @acme.departments.sort, Department.all.sort
      assert_equal @acme.roles.sort, Role.all.sort
      assert_nil User.find_by(email_address: users(:admin).email_address)
    end
  end

  test "models belonging to a user are scoped through the user" do
    admin_session = users(:admin).sessions.create!
    owner_session = users(:acme_owner).sessions.create!

    Current.set(organization: @acme) do
      assert_equal [ owner_session ], Session.all.to_a
      assert_equal [ role_assignments(:one), role_assignments(:two), role_assignments(:acme_owner) ].sort, RoleAssignment.all.sort
      assert_not RoleAssignment.exists?(role_assignments(:admin).id)
      assert_nil Session.find_by(id: admin_session.id)
    end
  end

  test "new records are built in the current organization" do
    Current.set(organization: @acme) do
      assert_equal @acme, Department.new(name: "Sales").organization
    end
  end
end
