class OrganizationRegistrationService
  attr_reader :organization

  def initialize(params)
    @organization = Organization.new(params)
    @organization.users.each { |user| user.password = SecureRandom.base58(24) }
  end

  def call
    return false unless valid?

    ActiveRecord::Base.transaction do
      organization.save!
      owner_role = organization.roles.create!(name: "Owner", key: "owner", kind: :organization_owner, system: true)
      RoleAssignment.create!(user: owner, role: owner_role, assigned_by: owner, effective_from: Time.current)
    end

    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    organization.errors.add(:base, "Registration could not be completed. Please check the details and try again.")
    false
  end

  def owner
    organization.users.first
  end

  private
    def valid?
      organization.valid?
      organization.errors.add(:base, "Exactly one owner account is required.") unless organization.users.size == 1
      organization.errors.empty?
    end
end
