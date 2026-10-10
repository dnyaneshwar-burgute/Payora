module Admin
  class BaseController < ApplicationController
    before_action :require_platform_admin

    private
      def require_platform_admin
        redirect_to root_path, alert: "You are not authorized to access that page." unless Current.user.platform_admin?
      end
  end
end
