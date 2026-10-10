import { Card, Container } from "react-bootstrap"
import { Route, Routes } from "react-router-dom"

function Home() {
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
      </Routes>
    </Container>
  )
}
