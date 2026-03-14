// ── Login exceptions ───────────────────────────────────────────────────────

/// Thrown when no account exists for the supplied email address.
class UserNotFoundAuthException implements Exception {}

/// Thrown when the supplied password does not match the account's password.
class WrongPasswordAuthException implements Exception {}

// ── Registration exceptions ────────────────────────────────────────────────

/// Thrown when the supplied password does not meet the minimum strength
/// requirements of the auth provider.
class WeakPasswordAuthException implements Exception {}

/// Thrown when an account already exists for the supplied email address.
class EmailAlreadyInUseAuthException implements Exception {}

/// Thrown when the supplied email address is not in a valid format.
class InvalidEmailAuthException implements Exception {}

// ── Generic exceptions ─────────────────────────────────────────────────────

/// Thrown for unexpected errors that do not map to a specific exception type.
class GenericAuthException implements Exception {}

/// Thrown when an operation that requires authentication is attempted without
/// a signed-in user.
class UserNotLoggedInAuthException implements Exception {}
