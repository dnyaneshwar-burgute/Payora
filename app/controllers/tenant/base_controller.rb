module Tenant
  class BaseController < ApplicationController
    before_action :reject_platform_admin

    private
      def reject_platform_admin
        head :forbidden if Current.user.platform_admin?
      end
  end
end
