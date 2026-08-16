//! Application composition primitives.

/// The neutral application composition root.
#[derive(Debug, Default, Clone)]
pub struct App;

impl App {
    pub fn new() -> Self {
        Self
    }

    pub fn greeting(&self) -> &'static str {
        foundation::greeting()
    }
}
