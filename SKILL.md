---
name: "self-improvement"
description: "A two-mode self-improvement system for mastering a topic: Socratic tutoring for learning (Jane Street's socratic-tutor skill, integrated whole) and a Landau-school oral exam for assessment (random ticket, foundations question, novel application, no ladder). Use when the user wants to learn a topic deeply, be tutored or drilled, sit an exam on studied material, or run a study block that ends in certification rather than familiarity."
---

# Self-improvement: learn Socratically, certify by viva

Two modes, kept strictly separate. The separation is the design:
the learning mode may iterate on the material; the exam mode is
held-out — it measures, and nothing learned inside it may be
coached during it.

## Mode 1 — Learn (Socratic tutor)

Run `vendor/socratic-tutor-SKILL.md` as-is: diagnostic placement,
skill map at levels 0–5 per subskill, one question at a time, no
answers given, devil's advocate on correct answers, spaced review,
levels earned only on demonstrated performance. That file governs
the learning mode entirely.

## Mode 2 — Examine (Landau exam)

Run `landau-exam.md` (in this folder): a fresh random ticket of
three parts — core question, mandatory foundations (why) question,
novel application — a preparation interval, a defence, probing
until the edge is found, **no ladder**, and a per-part verdict
(Holds / Edge found at … / Fails at fundamentals) written to the
exam record before any teaching resumes.

## Rules that bind both modes

- **Mode is explicit.** A session is tutoring or exam, never a
  blend. The exam starts only on the user's appointment ("sit the
  exam", "draw a ticket", or a scheduled end-of-block exam) and
  ends when the verdict is delivered.
- **The exam is held-out.** Tickets are generated from the topic's
  full question space, never from the practised set; the examiner
  does not use knowledge of what tutoring emphasised.
- **State is split.** Learning state (skill map, levels,
  misconceptions) and the exam record (tickets, verdicts, named
  edges) are kept as separate sections of the topic's study file.
  Tutoring may read exam verdicts *after* they are written — the
  named edges become the tutoring agenda. Exam records are never
  edited by a tutoring session.
- **Levels vs verdicts.** A tutoring level says "performed in
  practice". Only an exam verdict says "certified". Do not let a
  level, however high, be described as mastery of the topic until
  a ticket covering it has been defended.
- **Guard.** Ordinary questions are answered ordinarily. Neither
  mode starts without the user's explicit ask — a false start
  costs an unwanted quiz or an unwanted exam.

## Instantiations

- Interview preparation instantiates this set with its own files
  (career repo, `resume/interview/`): the question bank is the
  question space, Socratic practice is Mode 1, the marked mock is
  Mode 2 with the four-axis rubric as its verdict form.
- Any other topic (a book, a course, a technology) gets a study
  file with: subskill list, learning state, exam record.
