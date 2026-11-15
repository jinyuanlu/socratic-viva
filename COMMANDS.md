# Command interface

Six commands, namespaced `/viva:`. Every command belongs to
exactly one mode, and the mode rules of SKILL.md are enforced at
the command level: learning commands refuse to run while an exam
is open, and the exam opens only when it is explicitly invoked.

## Learning mode (Socratic tutor)

### `/viva:learn [topic]`
Open or resume tutoring on a topic. New topic: create its study
file (subskill list, empty learning state, empty exam record) and
run the diagnostic placement before any teaching. Existing topic:
resume from the recorded skill map — weakest subskills first,
unless the user names a focus.

### `/viva:drill [subskill]`
A focused probing round on one subskill of the current topic —
the named one, or the lowest-level one if unnamed. Levels move
only on demonstrated performance, per the vendored tutor protocol.

### `/viva:review`
Spaced review: unannounced re-probes of material from earlier
sessions and earlier topics, drawn without warning. A failed
re-probe lowers that subskill's level in the learning state. This
is still learning mode — the ladder is available, failures are
teaching input.

## Exam mode (Landau exam)

### `/viva:exam [topic]`
Sit the exam. Draws a fresh held-out ticket (core question,
foundations question, novel application), runs the preparation
interval, the defence, and the probing, under the no-ladder rule
of `landau-exam.md`. Ends by writing the verdict to the exam
record. While an exam is open, `/viva:learn`, `/viva:drill`, and
`/viva:review` refuse, and no explanation of exam content is
available from any command until the verdict is written.

## The bridge

### `/viva:debrief`
Post-verdict only. Unlocks explanations of what the exam exposed:
the examiner's model answers, the reasoning behind each verdict,
and the conversion of named edges and missing foundations into
the tutoring agenda for the next learning sessions. Refuses if
the latest exam on the topic has no written verdict — there is no
debrief without a measurement to debrief.

## Meta

### `/viva:status [topic]`
Read-only. Shows the skill map with levels, the exam history with
verdicts, and — kept visually separate — what is merely practised
(levels, no exam) versus what is certified (a defended ticket).
Never reports a level as mastery.

## State

Per topic, one study file with two sections that mirror the mode
separation: `## Learning state` (skill map, levels, misconceptions
— written by learning commands) and `## Exam record` (tickets,
verdicts, named edges — written only by `/viva:exam`, read by
`/viva:debrief` and `/viva:status`, never edited by learning
commands).
