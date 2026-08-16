//! Shared project standards and primitives.

pub mod redaction;

pub use redaction::Redacted;
pub use secrecy::{ExposeSecret, SecretBox, SecretString};
pub use thiserror::Error;

/// A tiny placeholder that keeps the initial workspace wired together.
pub fn greeting() -> &'static str {
    "hello world"
}
