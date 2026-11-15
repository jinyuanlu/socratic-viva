# State: the study folder

All state is plain Markdown on the learner's own machine. Nothing
is sent anywhere by this plugin, and nothing is stored in the
plugin's own folder.

## Location

- Root: the folder named by the environment variable `VIVA_HOME`
  if it is set, otherwise `~/.viva` (a folder named `.viva` in the
  user's home folder).
- One folder per topic: `<root>/topics/<slug>/`.

## Finding a topic

The learner's text may be a name ("operating systems") or a
sentence ("Spanish, I want to reach B1 by June"). Proceed in this
order:

1. List the existing topic folders and the title line of each
   `charter.md`. If the learner's text clearly refers to one of
   them, in any wording or language, use it.
2. If it is close to one but not clearly the same, ask.
3. Otherwise it is a new topic. Its name is the shortest phrase
   that identifies the subject, normally one to four words, without
   the goal, the level, or the date: "Spanish", "TCP congestion
   control", "senior backend interview". The rest of the text is
   context for the charter.

The folder name (slug) is that name in lower case, in Unicode NFC
form, spaces replaced by `-`, keeping letters and digits of any
script and removing everything else. Examples: `Operating
Systems` → `operating-systems`, `日本語` → `日本語`, `Japonés` →
`japonés`. When a topic is created, tell the learner its name
once, so that they can use the same name later.

## Layout

    <root>/
      profile.md                 optional, learner-wide preferences
      topics/<slug>/
        charter.md               what the topic is: goal, standard, syllabus
        learning.md              practice state
        asked.md                 situations already used in practice
        exams/
          001-2026-01-31.md      one record per exam, numbered in order
          001-2026-01-31.key.md  its answer key

## Ownership

Each file has one writer. This table is the mechanism that keeps
the exam independent of the tutoring; follow it exactly.

| File | Learn mode | Exam mode | Status |
|---|---|---|---|
| `profile.md` | read; write when the learner asks | read | read |
| `charter.md` | create; amend only with the learner's agreement | read; create if missing | read |
| `learning.md` | read and write; **sealed while an exam is open** | **never read, never write** | read; sealed while an exam is open |
| `asked.md` | append only | the ticket writer reads it, to avoid what is on it | not needed |
| exam record, `Status: open` | see that it exists; read and write nothing | read and write | report that it exists |
| exam record, closed or abandoned | read | read; **never edit** | read |
| answer key, exam open | never | ticket writer writes it; grader reads it; the conductor never opens it | never |
| answer key, exam closed or abandoned | read | read; **never edit** | not needed |

An exam is *open* when a record in `exams/` has `Status: open`.
At most one exam per topic is open at a time.

In Claude Code a hook shipped with the plugin enforces the rules
in bold for the Read, Write, Edit and Grep tools, and refuses
shell commands that name a sealed file. In other tools these
rules rest on the instructions alone.

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
    - Diagnostic: done | pending

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

Rules for this file:

- The rows of the skill map are the syllabus areas of the charter,
  one row each, with the same numbers and the same names, word
  for word.
- `Level` is always a number from 0 to 5. Leave `Last tested` and
  `Next review` empty for an area that has not been worked on.
- `Checks at next level` counts the independent checks passed
  towards the next level. It returns to 0 when the level changes.
- `Diagnostic: pending` means some areas have a level of 0 only
  because they were never placed.
- A line under `## Sessions` is one sentence.
- `## Misconceptions` holds specific wrong beliefs only ("thinks
  X causes Y"). Something the learner does not know yet is not a
  misconception; the level already shows it.
- Add no other sections.

An exam is *undebriefed* when its status is `closed` or
`abandoned` and its number is not listed under
`## Debriefed exams`.

## `asked.md`

    # Asked: <topic>
    - YYYY-MM-DD | area <n> | <the situation, with its key numbers> | <what was asked about it>

One line for every question the tutor builds on a concrete
situation, example, exercise or text: in the diagnostic, in
teaching, in a review, in a debrief. It records the question
only, never the answer or how it went. Lines are added, never
changed or removed. The ticket writer reads this file so that an
exam does not repeat a situation the learner has practised on.

## `exams/NNN-YYYY-MM-DD.md`

    # Exam NNN: <topic>
    - Date: YYYY-MM-DD
    - Status: open | closed | abandoned
    - Conditions: <copied from the charter, plus anything unusual>

    ## Ticket
    1. Core (<area>): <question>
    2. Foundations (<area>): <question>
    3. Transfer (<area>): <question>

    ## Defence
    <per part, appended when that part stops: the first-pass answer,
    then every question and answer, word for word, and how it stopped>

    ## Probe review
    <every examiner question marked allowed or not allowed>

    ## Verdict
    - Part 1: Holds | Edge found at <point> | Fails at fundamentals: <missing foundation>
    - Part 2: ...
    - Part 3: ...
    - Overall: certifies <what the parts that hold show, or "nothing">; does not certify <the rest>

    ## Debrief notes
    <written after the verdict: a model answer for every part that
    did not hold, and the agenda this gives the next learning session>

The ticket is written to the file, with `Status: open`, before the
learner sees it. Once the status is `closed` or `abandoned` the
file is a record and is not edited again by anyone.

## `exams/NNN-YYYY-MM-DD.key.md`

    # Answer key: exam NNN, <topic>

    ## Part 1
    - Must contain: <what a correct first-pass answer includes>
    - Limit of the standard: <how deep the charter's standard goes here>
    - Also acceptable: <other defensible answers, or none>

    ## Part 2
    ...

Written before the learner sees the ticket, and never changed.
