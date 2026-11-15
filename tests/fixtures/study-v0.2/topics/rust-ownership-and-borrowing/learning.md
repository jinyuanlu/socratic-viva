# Learning state: Rust ownership and borrowing
- Updated: 2026-11-15
- Target level: 4

## Skill map
| Area | Level | Checks at next level | Last tested | Next review |
|---|---|---|---|---|
| Ownership, moves, and drop | unplaced | 0 | - | - |
| `Copy` and `Clone` | unplaced | 0 | - | - |
| Shared and mutable references: the aliasing rules | unplaced | 0 | - | - |
| Lifetimes and lifetime annotations | 3 | 2 | 2026-11-15 | 2026-11-16 |
| Borrowing in function signatures and structs | 3 | 0 | 2026-11-15 | 2026-11-16 |
| Slices and string types (`String` / `&str`) | unplaced | 0 | - | - |
| Interior mutability and shared ownership (`Rc`, `RefCell`, `Arc`, `Mutex`) | unplaced | 0 | - | - |
| Closures and captures | 4 | 0 | 2026-11-15 | 2026-11-16 |

## Misconceptions
- [open] Lifetimes: could not name or state subtyping/variance in exam 001. 2026-11-15: after covariance was explained, derived unaided why shrinking must be off behind `&mut` (dangling write); name "invariance" then given. Then predicted `Vec<&'static str>` by value (accepted) versus behind `&mut` (rejected) and inferred covariance of `Vec<T>` unaided. Both checks came right after explanation: level stays 3 until one delayed, unprompted recall.
- [open] Borrowing in signatures and structs: explains `&'a str` out of `&mut self` only by "`Copy`"; no general reborrowing rule (shared versus mutable deref).
- [open] Interior mutability: cannot say why `Cell` is sound (volunteered in exam 001; area not yet diagnosed).

## Sessions
- 2026-11-15: first session. No diagnostic had been run (charter was created in exam mode). Areas 4, 5, 8 placed provisionally from the exam 001 record; areas 1, 2, 3, 6, 7 unplaced until diagnosed. Debrief of exam 001 started.

## Debriefed exams
