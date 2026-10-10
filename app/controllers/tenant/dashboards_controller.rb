module Tenant
  class DashboardsController < BaseController
    def show
      @organization = Current.organization
      @users_count = User.count
      @departments_count = Department.count
      @roles_count = Role.count
    end
  end
end
