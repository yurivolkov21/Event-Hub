# API Error Convention

All backend errors should use a consistent response format.

## Standard Error Shape

```json
{
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Email is invalid"
    }
  ]
}
```

## Simple Error Shape

For simple errors:

```json
{
  "message": "Invalid email or password"
}
```

## HTTP Status Codes

- `200`: success
- `201`: created
- `400`: validation or bad request
- `401`: missing or invalid authentication
- `403`: authenticated but not allowed
- `404`: resource not found
- `409`: duplicate or conflict
- `500`: server error

## Validation Errors

Use Zod to validate request body and query params.

Example:

```json
{
  "message": "Validation failed",
  "errors": [
    {
      "field": "password",
      "message": "Password must contain at least 8 characters"
    }
  ]
}
```

## Flutter Handling

Flutter should:

- Show `message` as the main error.
- Show field-specific errors near form fields when available.
- Clear token and redirect to sign in on `401`.
- Keep the user on the same screen for validation errors.

## Backend Rules

- Do not leak stack traces in production.
- Do not reveal whether an email exists during forgot password flow.
- Log internal error details on server only.
- Keep response language consistent.
