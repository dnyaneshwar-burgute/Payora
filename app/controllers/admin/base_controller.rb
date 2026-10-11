module Admin
  class BaseController < ApplicationController
    before_action :require_platform_admin

    private
      def require_platform_admin
        return if Current.user.platform_admin?

        message = "You are not authorized to access that page."
        if request.format.json?
          render json: { error: message }, status: :forbidden
        else
          redirect_to root_path, alert: message
        end
      end
  end
end
