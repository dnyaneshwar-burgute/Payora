export class ApiError extends Error {
  baseError: string | null
  fieldErrors: Record<string, string[]>

  constructor(baseError: string | null, fieldErrors: Record<string, string[]> = {}) {
    super(baseError || "Something went wrong.")
    this.baseError = baseError
    this.fieldErrors = fieldErrors
  }
}

type ErrorBody = {
  error?: string | null
  field_errors?: Record<string, string[]>
}

function csrfToken() {
  return document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')?.content ?? ""
}

export async function api<T>(path: string, options: RequestInit = {}): Promise<T> {
  const headers = new Headers(options.headers)
  headers.set("Accept", "application/json")
  if (options.body) headers.set("Content-Type", "application/json")

  const token = csrfToken()
  if (token) headers.set("X-CSRF-Token", token)

  const response = await fetch(path, { ...options, headers, credentials: "same-origin" })

  if (response.status === 401 || response.redirected) {
    window.location.assign("/session/new")
    throw new ApiError("Sign in required.")
  }

  const contentType = response.headers.get("content-type") ?? ""
  const data: ErrorBody = contentType.includes("application/json") ? await response.json() : {}

  if (!response.ok) {
    throw new ApiError(data.error ?? null, data.field_errors ?? {})
  }

  return data as T
}
