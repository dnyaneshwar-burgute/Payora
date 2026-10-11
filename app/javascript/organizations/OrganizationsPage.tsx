import { useEffect, useState } from "react"
import { Alert, Button, ButtonGroup, Card, Spinner, Table } from "react-bootstrap"
import { Link, useSearchParams } from "react-router-dom"
import { ApiError, api } from "../api"
import StatusBadge, { humanizeStatus } from "./StatusBadge"
import type { OrganizationIndex, OrganizationStatus } from "./types"

const FALLBACK_STATUSES: OrganizationStatus[] = ["created", "approved", "rejected"]

function formatRegisteredAt(value: string) {
  return new Date(value).toLocaleString(undefined, { dateStyle: "medium", timeStyle: "short" })
}

export default function OrganizationsPage() {
  const [searchParams, setSearchParams] = useSearchParams()
  const requestedStatus = searchParams.get("status") ?? ""
  const [statuses, setStatuses] = useState<OrganizationStatus[]>(FALLBACK_STATUSES)
  const [organizations, setOrganizations] = useState<OrganizationIndex["organizations"]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const selectedStatus = statuses.includes(requestedStatus as OrganizationStatus) ? requestedStatus : ""

  useEffect(() => {
    const controller = new AbortController()
    const query = selectedStatus ? `?status=${encodeURIComponent(selectedStatus)}` : ""

    setLoading(true)
    setError(null)

    api<OrganizationIndex>(`/admin/organizations.json${query}`, { signal: controller.signal })
      .then((data) => {
        setStatuses(data.statuses)
        setOrganizations(data.organizations)
        setLoading(false)
      })
      .catch((caught: unknown) => {
        if (caught instanceof Error && caught.name === "AbortError") return

        setError(caught instanceof ApiError ? caught.message : "Organizations could not be loaded.")
        setLoading(false)
      })

    return () => controller.abort()
  }, [selectedStatus])

  function selectStatus(status: string) {
    const params = new URLSearchParams(searchParams)
    if (status) params.set("status", status)
    else params.delete("status")
    setSearchParams(params)
  }

  return (
    <>
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h1 className="h4 mb-0">Organizations</h1>
        <ButtonGroup size="sm">
          <Button variant={selectedStatus ? "outline-secondary" : "secondary"} onClick={() => selectStatus("")}>
            All
          </Button>
          {statuses.map((status) => (
            <Button
              key={status}
              variant={selectedStatus === status ? "secondary" : "outline-secondary"}
              onClick={() => selectStatus(status)}
            >
              {humanizeStatus(status)}
            </Button>
          ))}
        </ButtonGroup>
      </div>

      {error && <Alert variant="danger">{error}</Alert>}

      <Card className="shadow-sm">
        <Table hover responsive className="align-middle mb-0">
          <thead>
            <tr>
              <th>Name</th>
              <th>Host</th>
              <th>Status</th>
              <th>Registered</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={5} className="text-center text-muted py-4">
                  <Spinner animation="border" size="sm" className="me-2" />
                  Loading organizations
                </td>
              </tr>
            )}

            {!loading && organizations.length === 0 && (
              <tr>
                <td colSpan={5} className="text-center text-muted py-4">
                  No organizations found.
                </td>
              </tr>
            )}

            {!loading &&
              organizations.map((organization) => (
                <tr key={organization.id}>
                  <td>{organization.name}</td>
                  <td className="text-muted">{organization.host}</td>
                  <td>
                    <StatusBadge status={organization.status} />
                  </td>
                  <td className="text-muted small">{formatRegisteredAt(organization.created_at)}</td>
                  <td className="text-end">
                    <Link to={`/admin/organizations/${organization.id}`} className="btn btn-outline-primary btn-sm">
                      Review
                    </Link>
                  </td>
                </tr>
              ))}
          </tbody>
        </Table>
      </Card>
    </>
  )
}
