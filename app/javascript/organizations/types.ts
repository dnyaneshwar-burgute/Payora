export type OrganizationStatus = "created" | "approved" | "rejected"

export type OrganizationSummary = {
  id: number
  name: string
  host: string
  status: OrganizationStatus
  created_at: string
}

export type OrganizationOwner = {
  full_name: string
  email_address: string
}

export type OrganizationDetail = OrganizationSummary & {
  rejection_reason: string | null
  owners: OrganizationOwner[]
}

export type OrganizationIndex = {
  status: OrganizationStatus | null
  statuses: OrganizationStatus[]
  organizations: OrganizationSummary[]
}

export type OrganizationResponse = {
  organization: OrganizationDetail
  notice?: string
}
