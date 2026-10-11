module Tenant
  class DashboardsController < BaseController
    before_action :require_organization_owner, only: :roles

    def show
      @organization = Current.organization
      return unless Current.user.organization_owner?

      @users_count = User.count
      @departments_count = Department.count
    end

    def roles
      @organization = Current.organization
      counts = RoleAssignment.active.group(:role_id).distinct.count(:user_id)
      @role_user_counts = Role.order(:name).map { |role| [ role, counts.fetch(role.id, 0) ] }
    end

    private
      def require_organization_owner
        redirect_to tenant_dashboard_path, alert: "You are not authorized to access that page." unless Current.user.organization_owner?
      end
  end
end
