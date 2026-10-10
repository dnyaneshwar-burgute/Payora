import { Button, Card, Container, Nav, Navbar } from "react-bootstrap"
import { Link, Route, Routes } from "react-router-dom"

function Home() {
  return (
    <Card className="shadow-sm">
      <Card.Body>
        <Card.Title>Salary Management System</Card.Title>
        <Card.Text>React and Bootstrap are up and running.</Card.Text>
        <Button variant="primary" href="/session/new">
          Sign in
        </Button>
      </Card.Body>
    </Card>
  )
}

export default function App() {
  return (
    <>
      <Navbar bg="dark" data-bs-theme="dark" expand="md">
        <Container>
          <Navbar.Brand as={Link} to="/">
            Salary Management
          </Navbar.Brand>
          <Navbar.Toggle aria-controls="main-nav" />
          <Navbar.Collapse id="main-nav">
            <Nav className="ms-auto">
              <Nav.Link href="/session/new">Sign in</Nav.Link>
            </Nav>
          </Navbar.Collapse>
        </Container>
      </Navbar>

      <Container className="py-4">
        <Routes>
          <Route path="/" element={<Home />} />
        </Routes>
      </Container>
    </>
  )
}
