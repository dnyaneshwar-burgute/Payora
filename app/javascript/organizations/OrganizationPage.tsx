import { FormEvent, useEffect, useState } from "react"
import { Alert, Button, Card, Col, Form, Row, Spinner } from "react-bootstrap"
import { Link, useParams } from "react-router-dom"
import { ApiError, api } from "../api"
import StatusBadge from "./StatusBadge"
import type { OrganizationDetail, OrganizationResponse } from "./types"

function formatRegisteredAt(value: string) {
  return new Date(value).toLocaleString(undefined, { dateStyle: "long", timeStyle: "short" })
}

export default function OrganizationPage() {
  const { id } = useParams()
  const [organization, setOrganization] = useState<OrganizationDetail | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [notice, setNotice] = useState<string | null>(null)
  const [reason, setReason] = useState("")
  const [fieldErrors, setFieldErrors] = useState<Record<string, string[]>>({})
  const [submitting, setSubmitting] = useState<"approve" | "reject" | null>(null)

  useEffect(() => {
    const controller = new AbortController()

    setLoading(true)
    setError(null)
    setNotice(null)
    setOrganization(null)

    api<OrganizationResponse>(`/admin/organizations/${id}.json`, { signal: controller.signal })
      .then((data) => {
        setOrganization(data.organization)
        setReason(data.organization.rejection_reason ?? "")
        setLoading(false)
      })
      .catch((caught: unknown) => {
        if (caught instanceof Error && caught.name === "AbortError") return

        setError(caught instanceof ApiError ? caught.message : "This organization could not be loaded.")
        setLoading(false)
      })

    return () => controller.abort()
  }, [id])

  useEffect(() => {
    document.title = organization ? organization.name : "Organizations"
  }, [organization])

  async function review(event: "approve" | "reject") {
    if (!organization) return

    setSubmitting(event)
    setError(null)
    setNotice(null)
    setFieldErrors({})

    try {
      const data = await api<OrganizationResponse>(`/admin/organizations/${organization.id}/change_state`, {
        method: "PATCH",
        body: JSON.stringify({
          event,
          rejection_reason: event === "reject" ? reason : undefined,
        }),
      })
      setOrganization(data.organization)
      setNotice(data.notice ?? null)
      setReason(data.organization.rejection_reason ?? "")
    } catch (caught) {
      if (caught instanceof ApiError) {
        setError(caught.baseError ?? (Object.keys(caught.fieldErrors).length === 0 ? caught.message : null))
        setFieldErrors(caught.fieldErrors)
      } else {
        setError("This organization could not be reviewed.")
      }
    } finally {
      setSubmitting(null)
    }
  }

  function reject(event: FormEvent) {
    event.preventDefault()
    void review("reject")
  }

  if (loading) {
    return (
      <div className="text-muted py-4">
        <Spinner animation="border" size="sm" className="me-2" />
        Loading organization
      </div>
    )
  }

  if (!organization) {
    return (
      <>
        <Link to="/admin/organizations" className="small text-decoration-none">
          ← All organizations
        </Link>
        {error && (
          <Alert variant="danger" className="mt-3">
            {error}
          </Alert>
        )}
      </>
    )
  }

  const reasonErrors = fieldErrors.rejection_reason ?? []

  return (
    <div className="col-lg-8 mx-auto">
      <Link to="/admin/organizations" className="small text-decoration-none">
        ← All organizations
      </Link>

      <div className="d-flex justify-content-between align-items-center mt-2 mb-3">
        <h1 className="h4 mb-0">{organization.name}</h1>
        <StatusBadge status={organization.status} />
      </div>

      {notice && <Alert variant="success">{notice}</Alert>}
      {error && <Alert variant="danger">{error}</Alert>}

      <Card className="shadow-sm mb-4">
        <Card.Body>
          <dl className="row mb-0">
            <dt className="col-sm-4">Host</dt>
            <dd className="col-sm-8">{organization.host}</dd>

            <dt className="col-sm-4">Registered</dt>
            <dd className="col-sm-8">{formatRegisteredAt(organization.created_at)}</dd>

            <dt className="col-sm-4">Owner</dt>
            <dd className="col-sm-8">
              {organization.owners.map((owner) => (
                <div key={owner.email_address}>
                  {owner.full_name} &lt;{owner.email_address}&gt;
                </div>
              ))}
            </dd>

            {organization.status === "rejected" && organization.rejection_reason && (
              <>
                <dt className="col-sm-4">Rejection reason</dt>
                <dd className="col-sm-8" style={{ whiteSpace: "pre-wrap" }}>
                  {organization.rejection_reason}
                </dd>
              </>
            )}
          </dl>
        </Card.Body>
      </Card>

      {organization.status === "created" && (
        <Row className="g-3">
          <Col md={5}>
            <Card className="shadow-sm h-100">
              <Card.Body>
                <h2 className="h6">Approve</h2>
                <p className="small text-muted">The owner will receive an invitation email to set their password.</p>
                <Button
                  variant="success"
                  className="w-100"
                  disabled={submitting !== null}
                  onClick={() => void review("approve")}
                >
                  {submitting === "approve" ? "Approving…" : "Approve organization"}
                </Button>
              </Card.Body>
            </Card>
          </Col>

          <Col md={7}>
            <Card className="shadow-sm h-100">
              <Card.Body>
                <h2 className="h6">Reject</h2>
                <Form onSubmit={reject}>
                  <Form.Group className="mb-3">
                    <Form.Label className="small">Reason</Form.Label>
                    <Form.Control
                      as="textarea"
                      rows={3}
                      required
                      value={reason}
                      isInvalid={reasonErrors.length > 0}
                      onChange={(event) => {
                        setReason(event.target.value)
                        setFieldErrors({})
                      }}
                    />
                    <Form.Control.Feedback type="invalid">{reasonErrors.join(" ")}</Form.Control.Feedback>
                  </Form.Group>
                  <Button type="submit" variant="outline-danger" className="w-100" disabled={submitting !== null}>
                    {submitting === "reject" ? "Rejecting…" : "Reject organization"}
                  </Button>
                </Form>
              </Card.Body>
            </Card>
          </Col>
        </Row>
      )}
    </div>
  )
}
