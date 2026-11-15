---
name: status
description: "Socratic Viva, status: a read-only report of the learner's study folder. For each topic it shows what has been practised (skill map, reviews due) and, separately, what has been certified by exam (verdicts by area). Use when the learner runs this command or asks what they have practised, what is certified, or what is due for review."
argument-hint: "[topic]"
---

# Viva: status

Report the state of the learner's study folder. **Read only: write
no file.** The learner's text after the command may name one topic.

Read [state.md](../../protocol/state.md) first for the location
and format of the files. The path is relative to the folder that
contains this file.

Use the working language from the profile; if none is set, use the
language the learner writes in. If the profile says
`Display: plain`, use plain lists with numbers and no bar
characters.

## No topic given

One line per topic: name, goal and deadline (with the days left),
number of areas at or above the target level, number of areas
certified, reviews due today, and a flag if an exam is open or
undebriefed. If the study folder is empty, say so and name the
learn command as the way to begin.

## One topic

Show two blocks and keep them apart.

**Practised** (from `learning.md`): the skill map with levels, the
areas due for review, and the open misconceptions.

**Certified** (from closed exam files): for each syllabus area,
the most recent verdict that covered it, with the exam number and
date; or "not examined". Then the overall line of the latest exam.

Then, if they apply:

- an exam is open. Report only that it exists. Do not show its
  ticket;
- an exam is closed but not yet debriefed;
- an exam was abandoned. It certifies nothing.

## Rules

- Never call a level mastery, and never merge the two blocks into
  one score. A level says "performed in practice". Only a verdict
  of "Holds" certifies, and only for the area and date it names.
- An area certified long ago may no longer hold. Show the date and
  let the learner judge. Do not add a judgement of your own.
- After a status report this conversation knows the learning
  state, so the exam command will ask for a new conversation. Say
  so if the learner seems about to sit an exam.
