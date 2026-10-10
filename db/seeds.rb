# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

platform_admin_role = Role.find_or_create_by!(kind: "platform_admin") do |role|
  role.name = "Platform Admin"
  role.key = "platform_admin"
  role.system = true
end

platform = Organization.find_or_create_by!(host: ENV.fetch("PLATFORM_HOST", "platform.localhost")) do |organization|
  organization.name = "Platform"
  organization.status = "approved"
end

admin = User.find_or_create_by!(email_address: ENV.fetch("PLATFORM_ADMIN_EMAIL", "admin@example.com")) do |user|
  user.organization = platform
  user.first_name = "Platform"
  user.last_name = "Admin"
  user.password = ENV.fetch("PLATFORM_ADMIN_PASSWORD") { Rails.env.production? ? raise("PLATFORM_ADMIN_PASSWORD is required") : "password" }
end

unless admin.role_assignments.active.exists?(role: platform_admin_role)
  RoleAssignment.create!(user: admin, role: platform_admin_role, assigned_by: admin, effective_from: Time.current)
end
