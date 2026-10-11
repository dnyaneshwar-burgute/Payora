class ApplicationRecord < ActiveRecord::Base
  include OrganizationScoped

  primary_abstract_class
end
