import { Badge } from "react-bootstrap"
import type { OrganizationStatus } from "./types"

const BADGE_BACKGROUNDS: Record<OrganizationStatus, string> = {
  created: "warning",
  approved: "success",
  rejected: "danger",
}

export function humanizeStatus(status: string) {
  return status.replace(/_/g, " ").replace(/\b\w/g, (letter) => letter.toUpperCase())
}

export default function StatusBadge({ status }: { status: OrganizationStatus }) {
  return <Badge bg={BADGE_BACKGROUNDS[status] ?? "secondary"}>{humanizeStatus(status)}</Badge>
}
