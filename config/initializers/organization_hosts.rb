# Let organization hosts through Host Authorization. The proc runs on each
# request, so a newly registered subdomain works without a restart.
# Appended only when an allowlist is already active (development, or an
# explicit list in another environment). An empty list leaves the check off.
if Rails.application.config.hosts.present?
  Rails.application.config.hosts << ->(host) { Organization.known_host?(host) }
end
