# State: the study folder

All state is plain Markdown on the learner's own machine. Nothing
is sent anywhere by this plugin, and nothing is stored in the
plugin's own folder.

## Location

- Root: the folder named by the environment variable `VIVA_HOME`
  if it is set, otherwise `~/.viva` (a folder named `.viva` in the
  user's home folder).
- One folder per topic: `<root>/topics/<slug>/`.
- Slug: the topic name in lower case, spaces replaced by `-`,
  keeping letters and digits of any script and removing everything
  else. Examples: `Operating Systems` → `operating-systems`,
  `日本語 N3` → `日本語-n3`.
- If the learner names a topic that is close to an existing folder,
  ask which one they mean. Do not create a near-duplicate.

## Layout

    <root>/
      profile.md                 optional, learner-wide preferences
      topics/<slug>/
        charter.md               what the topic is: goal, standard, syllabus
        learning.md              practice state
        exams/
          001-2026-01-31.md      one file per exam, numbered in order

## Ownership

Each file has one writer. This table is the mechanism that keeps
the exam independent of the tutoring; follow it exactly.

| File | Learn mode | Exam mode | Status |
|---|---|---|---|
| `profile.md` | read; write when the learner asks | read | read |
| `charter.md` | create; amend only with the learner's agreement | read; create if missing | read |
| `learning.md` | read and write | **never read, never write** | read |
| `exams/*.md` with `Status: open` | see that it exists; read and write nothing | read and write | report that it exists |
| `exams/*.md`, closed or abandoned | read | read; **never edit** | read |

An exam is *open* when a file in `exams/` has `Status: open`. At
most one exam per topic is open at a time.

## Dates

Write dates as `YYYY-MM-DD`. Take today's date from the
environment. If it is not available, ask the learner. Never guess.

## `profile.md` (optional)

    # Profile
    - Working language: <language used for instruction and records>
    - Display: bars | plain      (plain = no bar characters, for screen readers)
    - Notes: <anything the learner wants every session to respect>

If there is no profile, use the language the learner writes in and
`bars` display.

## `charter.md`

The charter defines the topic and its question space. Both modes
read it. It contains no record of what was practised.

    # <Topic name as the learner wrote it>
    - Goal: <what the learner wants to be able to do>
    - Deadline: <YYYY-MM-DD, or none>
    - Kind: concepts | problem-solving | language | interview | mixed
    - Standard: <what "certified" means for this topic>
    - Working language: <language>
    - Target language: <language topics only>
    - Exam conditions: closed-book | open-book; text | voice

    ## Syllabus
    1. <area>
    2. <area>
    (4 to 10 areas. For a broad topic use two levels.)

    ## Out of scope
    - <what this topic does not include>

    ## Sources
    - <books, courses, job description, notes: optional>

    ## Changes
    - YYYY-MM-DD: <what changed and why>

A syllabus change moves the boundary of what the exam may ask.
Make one only when the learner agrees, and log it under
`## Changes`. Never remove an area because it is going badly.

## `learning.md`

    # Learning state: <topic>
    - Updated: YYYY-MM-DD
    - Target level: 4

    ## Skill map
    | Area | Level | Checks at next level | Last tested | Next review |
    |---|---|---|---|---|
    | <syllabus area> | 0-5 | 0-2 | YYYY-MM-DD | YYYY-MM-DD |

    ## Misconceptions
    - [open] <area>: <the specific wrong idea>
    - [resolved YYYY-MM-DD] <area>: <the wrong idea>

    ## Sessions
    - YYYY-MM-DD: <one line: what was worked on, what changed>

    ## Debriefed exams
    - 001

The rows of the skill map are the syllabus areas of the charter,
one row each. An exam is *undebriefed* when it is closed and its
number is not listed under `## Debriefed exams`.

## `exams/NNN-YYYY-MM-DD.md`

    # Exam NNN: <topic>
    - Date: YYYY-MM-DD
    - Status: open | closed | abandoned
    - Conditions: <copied from the charter, plus anything unusual>

    ## Ticket
    1. Core (<area>): <question>
    2. Foundations (<area>): <question>
    3. Transfer (<area>): <question>

    ## Defence notes
    <per part: what the learner claimed, where each line of probing stopped>

    ## Verdict
    - Part 1: Holds | Edge found at <point> | Fails at fundamentals: <missing foundation>
    - Part 2: ...
    - Part 3: ...
    - Overall: certifies <what>; does not certify <what>

    ## Debrief notes
    <written after the verdict: a model answer for every part that
    did not hold, and the agenda this gives the next learning session>

The ticket is written to the file, with `Status: open`, before the
learner sees it. Once the status is `closed` or `abandoned` the
file is a record and is not edited again by anyone.
