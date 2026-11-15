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

Learn and exam find the topic in this way. The learner's text may
be a name or a sentence with context. The examples assume one
existing topic, "Photography basics", whose syllabus includes
"Exposure: aperture, shutter, ISO" and "Composition".

1. **Check for unfinished work.** If `<root>/staging` exists, or
   the last line of `<root>/journal` says neither `done` nor
   `aborted`, a rename or merge was not finished. Say so, name
   `/viva:topics` as the command that finishes it, and stop.
2. **Search once.** Make one Grep call: path `<root>/topics`,
   glob `charter.md`, pattern
   `^(# |- Also called:|- Goal:|- Standard:|[0-9]+\. )`.
   It returns the title, other names, goal, standard and syllabus
   of every topic. Do not search `<root>` itself, do not open
   the charters one by one, and do not read a practice record.
3. **Classify** the text as exactly one of these four.
   - **Same**: it equals a title or an `Also called` name, or it
     is plainly the same subject and purpose in other words or
     in another language ("photo basics"). Use that topic. Ask
     nothing. A goal, a level or a date in the text is context,
     not material: it never turns Same into Extends.
   - **Area**: a known topic plus something inside its syllabus
     ("photography exposure"). Use that topic, with that area as
     the focus. Ask nothing.
   - **Extends**: the subject of a known topic plus material
     that is not in its syllabus ("photography and darkroom
     printing"). Ask once, with three choices: continue the
     topic as it is; add the material as new areas, which is a
     syllabus change; or make a separate topic. Recommend the
     separate topic when the goal or the standard would differ.
     Exam mode offers the first and the third only.
   - **New**: everything else ("Portuguese"). A different
     subject in the same field is also New ("videography"). Ask
     nothing.
4. **Name the topic first.** Open the reply with one line that
   names the topic you resolved, or the new topic, for example
   `Topic: Photography basics.` A wrong match is then visible at
   once.

The name of a new topic is the shortest phrase that identifies
the subject, normally one to four words, without the goal, the
level, or the date. The rest of the text is context for the
charter.

The folder name (slug) is that name in lower case, in Unicode NFC
form, spaces replaced by `-`, keeping letters and digits of any
script and removing everything else. Examples: `Operating
Systems` → `operating-systems`, `日本語` → `日本語`, `Japonés` →
`japonés`.

When a separate topic is made out of an Extends choice, add one
line under `## Out of scope` in each of the two charters, naming
the other topic. Exam mode adds it to the new charter only.

## Layout

    <root>/
      format                     format number of this folder (see Compatibility)
      profile.md                 optional, learner-wide preferences
      journal                    log of renames and merges
      staging/                   a merge that is not finished
      archive/<stamp>/           what a merge replaced
      topics/<slug>/
        charter.md               what the topic is: goal, standard, syllabus
        learning.md              practice state
        asked.md                 situations already used in practice
        exams/
          001-2026-01-31.md      one record per exam, numbered in order
          001-2026-01-31.key.md  its answer key
          from-<source>/         exams of a topic merged into this one

## Ownership

Each file has one writer. This table is the mechanism that keeps
the exam independent of the tutoring; follow it exactly.

| File | Learn mode | Exam mode | Status | Topics |
|---|---|---|---|---|
| `profile.md` | read; write when the learner asks or agrees | read | read | read |
| `charter.md` | create; amend only with the learner's agreement | read; create if missing | read | read; write only the staged copy of a merge |
| `learning.md` | read and write; **sealed while an exam is open** | **never read, never write** | read; sealed while an exam is open | read; write only the staged copy of a merge; sealed while an exam is open |
| `asked.md` | append only | the ticket writer reads it, to avoid what is on it | not needed | never; the topic tool appends to it in a merge |
| exam record, `Status: open` | see that it exists; read and write nothing | read and write | report that it exists | see that it exists; rename and merge nothing |
| exam record, closed or abandoned | read | read; **never edit** | read | read; **never edit** |
| answer key, exam open | never | ticket writer writes it; grader reads it; the conductor never opens it | never | never |
| answer key, exam closed or abandoned | read | read; **never edit** | not needed | never |
| `exams/from-*/` | read | the ticket writer reads the tickets; **never edit** | read | **never edit** |
| `journal`, `staging/`, `archive/` | never write | never write | not needed | only through the topic tool, except the two staged files above |

An exam is *open* when a record in `exams/` has `Status: open`.
At most one exam per topic is open at a time.

In Claude Code a hook shipped with the plugin enforces the rules
in bold for the Read, Write, Edit and Grep tools, and refuses
shell commands that name a sealed file. In other tools these
rules rest on the instructions alone.

## Renames and merges

Only the topics command renames or merges a topic, and only with
the topic tool shipped with the plugin. No mode moves, copies or
deletes a topic folder by hand.

- `exams/from-<source>/` holds the exam records and answer keys
  of a topic that was merged into this one, unchanged, and
  `source-charter.md`, the charter they were written and graded
  against. Read them against that charter. They are history
  only: their verdicts certify nothing in this topic.
- `<root>/archive/<stamp>/topics/` holds the original folders
  that a merge replaced. No skill reads it. The learner may
  delete it.
- `<root>/staging/` and `<root>/journal` belong to the topic
  tool.

## Compatibility

A study folder holds months of a learner's work. Every version of
the plugin must go on using a folder written by any earlier
version.

- **Additive only.** A version may add a file, a section or a
  line. It never renames or removes one, and never changes what
  an existing one means.
- **Missing means empty.** A file, section or line that an older
  version did not write is read as empty or as its default. Never
  refuse to work because one is absent.
- **Records are never reshaped.** A closed or abandoned exam
  keeps the layout it was written in. Do not convert it.
- **Checks report, they do not block.** If the topic tool finds a
  fault in older data, the topics command reports it. Learning,
  exams and status go on as well as they can.
- **Format number.** `<root>/format` holds one number. This
  version writes `1` when it creates a study folder, and a folder
  without the file is format 1. If the number is higher, a newer
  version wrote the folder: read it, write nothing, and tell the
  learner to update the plugin.

What an older folder may look like, and how to treat it:

| Older shape | Treat as |
|---|---|
| Exam record with no answer key | Valid. Debrief from its `## Debrief notes` |
| Exam record with `## Defence notes`, and no `## Probe review` | Valid. Read the notes as the defence |
| `learning.md` with no `Diagnostic:` line | `Diagnostic: done` |
| Skill-map row names shortened, or without numbers | Match rows to areas by order. Write the full names the next time the file is saved |
| A skill-map level that is not a number, such as `unplaced` | Level 0, and `Diagnostic: pending`. Write the number the next time the file is saved |
| No `asked.md` | Start one at the next question. An exam may repeat practice from before it existed |
| Charter with no `Also called` line; profile with no `## About the learner` | Empty |

Real study folders written by earlier versions are kept in the
repository under `tests/fixtures/`, and every version is tested
against them.

## Dates

Write dates as `YYYY-MM-DD`. Take today's date from the
environment. If it is not available, ask the learner. Never guess.

## `profile.md` (optional)

    # Profile
    - Working language: <language used for instruction and records>
    - Display: bars | plain      (plain = no bar characters, for screen readers)
    - Notes: <anything the learner wants every session to respect>

    ## About the learner
    - <role, level, background, usual goals: one fact per line>

If there is no profile, use the language the learner writes in and
`bars` display.

`## About the learner` is optional. The tutor adds a fact to it,
with the learner's agreement, the first time the fact comes up.
Every later charter is drafted from it, so that the learner is
not asked again.

## `charter.md`

The charter defines the topic and its question space. Both modes
read it. It contains no record of what was practised.

    # <Topic name as the learner wrote it>
    - Also called: <other names of this topic, separated by "; ">
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

The `Also called` line is optional. It is written only by a
rename, by a merge, or when the learner says in words that a name
which did not match exactly means this topic. Do not ask a
question in order to get that answer. Learn mode writes the line
then; exam mode never writes the charter of an existing topic.
No name on it may equal the title or an `Also called` name of
another topic.

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
