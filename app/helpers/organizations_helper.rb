module OrganizationsHelper
  STATUS_BADGE_CLASSES = {
    "created" => "text-bg-warning",
    "approved" => "text-bg-success",
    "rejected" => "text-bg-danger"
  }.freeze

  def organization_status_badge(organization)
    tag.span(organization.status.humanize, class: "badge #{STATUS_BADGE_CLASSES.fetch(organization.status, "text-bg-secondary")}")
  end
end
