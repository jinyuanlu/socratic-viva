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

If the study folder is empty, say so and name the learn command as
the way to begin. If it holds exactly one topic, give the report
for that topic (next section). Otherwise give an overview and
nothing more: exactly one line per topic, with the name, the
deadline and days left, areas at or above the target level, areas
certified, reviews due today, and a short note if an exam is
open, undebriefed, or abandoned.

## One topic

Show two blocks and keep them apart.

**Practised** (from `learning.md`): the skill map with levels and
full area names, the areas due for review, and the open
misconceptions.

**Certified** (from closed exam files): for each syllabus area,
under its full name, the most recent verdict that covered it, with
the exam number and date; or "not examined". An area counts as
certified only if that verdict is "Holds". Abandoned exams do not
appear in this block. Then the overall line of the latest closed
exam, word for word.

Then, if they apply:

- an exam is open. Report only that it exists. Do not show its
  ticket, and do not open `learning.md` for this topic: the
  practice record is sealed until the exam ends, so the Practised
  block says only that;
- an exam is closed but not yet debriefed;
- an exam was abandoned. It certifies nothing.

A topic may have a charter and exams but no `learning.md`. Then
the Practised block says that no tutoring has taken place yet.

## Rules

- Read only the files of the study folder. Do not list or read
  the working directory.
- Never call a level mastery, and never merge the two blocks into
  one score. A level says "performed in practice". Only a verdict
  of "Holds" certifies, and only for the area and date it names.
- An area certified long ago may no longer hold. Show the date and
  let the learner judge. Do not add a judgement of your own.
- After a status report this conversation knows the learning
  state, so the exam command will ask for a new conversation. Say
  so if the learner seems about to sit an exam.
