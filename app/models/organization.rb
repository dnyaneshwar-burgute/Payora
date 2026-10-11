class Organization < ApplicationRecord
  include AASM

  # Host Authorization passes the raw Host header, which may include a port.
  def self.known_host?(request_host)
    Rails.logger.info("************ #{request_host} **********")
    hostname = request_host.to_s.sub(/:\d+\z/, "").downcase
    return false if hostname.blank?

    exists?(host: hostname)
  end

  has_many :roles, dependent: :destroy, inverse_of: :organization
  has_many :departments, dependent: :delete_all, inverse_of: :organization
  has_many :users, dependent: :restrict_with_error, inverse_of: :organization

  accepts_nested_attributes_for :users

  normalizes :host, with: ->(host) { host.strip.downcase }
  normalizes :rejection_reason, with: ->(reason) { reason.strip.presence }

  validates :name, presence: true
  validates :host, presence: true, uniqueness: true
  validates :rejection_reason, presence: true, if: :rejected?

  aasm column: :status, whiny_persistence: false do
    state :created, initial: true
    state :approved, :rejected

    event :approve, after_commit: :invite_owners do
      transitions from: :created, to: :approved
    end

    event :reject do
      transitions from: :created, to: :rejected
    end
  end

  def owner_role
    roles.organization_owner.first
  end

  def owners
    users.joins(role_assignments: :role).merge(Role.organization_owner).merge(RoleAssignment.active).distinct
  end

  private
    def invite_owners(invited_by)
      owners.each do |owner|
        UserInvitationService.new(user: owner, role: owner_role, invited_by: invited_by).call
      end
    end
end
