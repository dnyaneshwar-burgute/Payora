import { useEffect } from "react"
import { Card, Container } from "react-bootstrap"
import { Route, Routes } from "react-router-dom"
import OrganizationPage from "./organizations/OrganizationPage"
import OrganizationsPage from "./organizations/OrganizationsPage"

function Home() {
  useEffect(() => {
    document.title = "Salary Management System"
  }, [])

  return (
    <Card className="shadow-sm">
      <Card.Body>
        <Card.Title>Salary Management System</Card.Title>
        <Card.Text>React and Bootstrap are up and running.</Card.Text>
      </Card.Body>
    </Card>
  )
}

export default function App() {
  return (
    <Container className="py-4">
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/admin/organizations" element={<OrganizationsPage />} />
        <Route path="/admin/organizations/:id" element={<OrganizationPage />} />
      </Routes>
    </Container>
  )
}
