# Restricts every query to Current.organization while it is set (i.e. on an
# organization's domain). Use `unscoped` for deliberate cross-organization access.
module OrganizationScoped
  extend ActiveSupport::Concern

  class_methods do
    def scoped_to_organization(through: nil)
      if through
        default_scope { where(through => reflect_on_association(through).klass.all) if Current.organization }
      else
        default_scope { where(organization: Current.organization) if Current.organization }
      end
    end
  end
end
