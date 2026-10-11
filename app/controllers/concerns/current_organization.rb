module CurrentOrganization
  extend ActiveSupport::Concern

  included do
    before_action :set_current_organization
  end

  private
    def set_current_organization
      Current.organization = OrganizationDomain.find(request)
    end
end
