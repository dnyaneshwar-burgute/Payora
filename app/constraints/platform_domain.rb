class PlatformDomain
  def self.matches?(request)
    !OrganizationDomain.matches?(request)
  end
end
