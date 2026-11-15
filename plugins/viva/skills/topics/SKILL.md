---
name: topics
description: "Socratic Viva, topics: lists the topics in the learner's study folder with their other names, suggests which duplicate topics to merge, and renames or merges a topic without losing any record. Runs only when the learner invokes this command."
argument-hint: "[rename <topic> to <name> | merge <source> into <target>]"
disable-model-invocation: true
---

# Viva: topics

You keep the list of topics in order. The learner's text after
the command is empty, or `rename <topic> to <name>`, or
`merge <source> into <target>`.

Read [state.md](../../protocol/state.md) first: where the study
folder is, the file formats, and "Renames and merges". The path
is relative to the folder that contains this file.

Use the working language from the profile; if none is set, use
the language the learner writes in.

## The topic tool

All moving and checking of folders is done by a shell script,
`../../tools/topic.sh`, relative to the folder that contains this
file. Run it with `sh`, with every argument in double quotes:

    sh "<tool>" check-root "<root>"
    sh "<tool>" rename "<root>" "<old-folder>" "<new-folder>" "<new title>"
    sh "<tool>" stage  "<root>" "<source-folder>" "<target-folder>"
    sh "<tool>" commit "<root>" "<source-folder>" "<target-folder>"
    sh "<tool>" abort  "<root>"

`<root>` is the study folder. A folder argument is a folder name
under `<root>/topics`, not a path.

- When the tool refuses, tell the learner its reason. Never do by
  hand what it refused.
- It refuses a rename or a merge while any exam in the study
  folder is open, because the files of that exam must not move.
  Tell the learner to finish or close the exam with the exam
  command first.
- It refuses a merge while the source topic has an exam that is
  not debriefed. The learn command debriefs it.
- If your tool cannot run shell commands, or `sh` is missing, say
  that rename and merge are not available here. Do not move, copy
  or edit topic folders by hand.

Before a rename or a merge, tell the learner to close other Viva
conversations: they may still write to the old folder. For a
merge, say it in the proposal of step 1. For a rename, say it and
go on.

## No argument: the list

1. Run `check-root` and report everything it finds. If it reports
   an unfinished operation, offer two ways out and wait: finish
   the merge (step 3 below on the staged copy, then `commit`), or
   `abort`, which changes no topic.
2. Search the charters as state.md describes ("Finding a topic",
   step 2), with `- Kind:`, `- Working language:` and
   `- Exam conditions:` added to the pattern.
3. List every topic, one line each: its name and its other names.
4. Then give merge suggestions. Suggest a merge when two topics
   have two or more syllabus areas that cover the same material:
   "X and Y share areas A, B: merge Y into X."
   - Merge into the topic with more record: more exams; if equal,
     more lines under `## Sessions`; if equal, the older topic.
     If a practice record is sealed, compare without it.
   - If the kind, the working language, the standard or the exam
     conditions differ, recommend against the merge and say which
     of them differs.
   - If no two topics overlap in this way, say so in one line.

Change nothing in this mode.

## rename <topic> to <name>

1. Find the topic by the search of state.md. It must be an
   existing topic; if the text does not plainly name one, ask.
2. Work out the new folder name from the new name, by the slug
   rule of state.md.
3. Run `rename`. The tool moves the folder, changes the title
   lines, keeps the old name under `Also called`, and logs the
   change. Edit nothing by hand.
4. Report the old name, the new name, and that the old name still
   finds the topic.

## merge <source> into <target>

Find both topics by the search of state.md. Then follow the four
steps in order.

**Step 1: propose and wait.** Read both charters.

- Refuse, with the reason, if the kind, the working language or
  the exam conditions differ. Go on only if the learner insists
  after reading the reason. If only the standard differs, say
  that the target's standard will apply.
- Map every source area: it is either *the same as* target area
  n, or *new*. A new area is appended with the next free number.
  The numbers and names of the target's areas never change.
- If the merged syllabus would have more than 10 areas, stop and
  advise against the merge. Do not restructure the syllabus to
  make it fit.
- Show the mapping and the complete merged syllabus. Say that the
  source's exams become history and certify nothing in the merged
  topic, because they were graded against the source's standard.
  Wait for the learner to agree.

**Step 2: stage.** Run `stage`. It prints the path of the staged
copy of the target, `<root>/staging/topics/<target-folder>/`. No
topic has changed yet.

**Step 3: edit the staged copy.** Edit only `charter.md` and
`learning.md` in the staged folder. Never edit anything under its
`exams/` folder, and never edit its `asked.md`: the tool has
already brought the source's lines across.

Staged `charter.md`:

- append the new areas to the syllabus;
- add the source's title and its `Also called` names to the
  `Also called` line;
- add one line under `## Changes`: today's date, the name of the
  source, and the mapping of every source area.

Staged `learning.md`, using the source's `learning.md`:

- a new area gets a row with the source row's values, under its
  new number and name;
- for a *same as* area keep the higher of the two levels, set
  `Checks at next level` to 0, keep the later `Last tested`, and
  set `Next review` to today. If neither topic has worked on the
  area, leave both dates empty;
- append the source's misconceptions, each under the name of the
  merged area;
- under `## Sessions`, add one line
  `- <today>: merged from "<source name>"; its sessions follow.`
  and then the source's session lines;
- keep the target's `Target level` and its `## Debriefed exams`
  list;
- write `Diagnostic: pending` if either record said so.

If one of the two topics has no `learning.md`, treat its areas as
never worked on: level 0, no dates, diagnostic pending. If
neither has one, write none.

**Step 4: commit.** Run `commit`. If it refuses, correct what it
names in the staged copy and run it again. Never work around it.
On success the merged topic is in place and both originals are in
`<root>/archive/<stamp>/topics/`.

Then report: what was merged into what, the area mapping, that
the source's exams are kept as history only, and where the
originals are.

## Housekeeping

- Work only inside the study folder.
- Never delete anything. Never read `<root>/archive`.
