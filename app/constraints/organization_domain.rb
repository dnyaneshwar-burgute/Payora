class OrganizationDomain
  ENV_KEY = "salary_management.organization"

  class << self
    def find(request)
      request.env.fetch(ENV_KEY) { request.env[ENV_KEY] = Organization.find_by(host: request.host) }
    end

    def matches?(request)
      find(request).present?
    end
  end
end
