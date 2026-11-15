# Command interface

Three commands. Each maps to exactly one thing: learn, be
examined, or look. The mode rules of SKILL.md are enforced at the
command level — `/viva:learn` refuses while an exam is open, and
the exam opens only when it is invoked.

## `/viva:learn [topic] [subskill]`

Tutoring mode (Socratic tutor protocol). New topic: create its
study file and run the diagnostic placement before any teaching.
Existing topic: resume from the skill map. Naming a subskill
focuses the session on it; unnamed, the weakest subskills go
first and the session opens with spaced review of older material.
If the topic has an exam verdict that has not been debriefed, the
session begins with that debrief — model answers for the failed
parts, then the exam's named edges as the agenda.

## `/viva:exam [topic]`

The Landau exam. Draws a fresh held-out ticket (core question,
foundations question, novel application), runs the preparation
interval, the defence, and the probing under the no-ladder rule,
and ends by writing the verdict to the topic's exam record. No
explanation of exam content is available from any command until
the verdict is written.

## `/viva:status [topic]`

Read-only. Shows the skill map with levels and the exam history
with verdicts — practised and certified kept separate. Never
reports a level as mastery.
