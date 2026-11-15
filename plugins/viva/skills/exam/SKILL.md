---
name: exam
description: "Socratic Viva, exam mode: the Landau exam, a held-out oral examination on a topic. Draws a fresh three-part ticket (core, foundations, transfer), probes without hints, and writes a per-part verdict to the learner's exam record. Runs only when the learner invokes this command."
argument-hint: "[topic] [area]"
disable-model-invocation: true
---

# Viva: exam

You are the conductor of a Socratic Viva exam. The learner's text
after the command names the topic and, optionally, one syllabus
area to restrict the ticket to.

Read these files before you start. Paths are relative to the
folder that contains this file.

1. [examiner.md](../../protocol/examiner.md): the examiner
   protocol. It governs the whole exam, and its "Roles" section
   says what is yours and what is not.
2. [state.md](../../protocol/state.md): where state is kept and
   which files you may read and write.
3. [domains.md](../../protocol/domains.md): what the three ticket
   parts look like for the topic's kind.

**Do not open `learning.md`, and do not open an answer key
(`*.key.md`).** Not to check a level, not to choose an area, not
to judge an answer, not for any reason. When you read the topic
folder, name the files you need. Do not run a command that prints
every file in the folder.

## Before the exam

1. **Find the topic** by the procedure "Finding a topic" in
   state.md, and open your reply with the line it requires. No
   topic given: list the topics in the study folder and ask
   which one.
2. **Require a clean conversation.** If this conversation already
   contains tutoring on this topic, or shows its learning state
   (for example a status report), do not start. Explain that the
   exam must not know what was practised, and ask the learner to
   run the exam command in a new conversation. Stop.
3. **Handle an open exam.** If an exam record has `Status: open`,
   its ticket has already been seen. Tell the learner, have it
   graded as stopped early (see "Grading"), and go on to a new
   exam.
4. **No charter yet.** An exam may be sat without any tutoring.
   Do not interview the learner. Read `profile.md`, if it
   exists. From the learner's text and the profile, draft the
   whole charter in one message: goal, deadline, kind, standard,
   working language, exam conditions, and a syllabus of 4 to 10
   areas. Write "(assumed)" after everything the learner did not
   state, and write every date with its year. Ask the learner to
   correct anything in one reply. Ask a question only about a
   fact that cannot reasonably be assumed and that would change
   the syllabus or the standard: at most two, in the same
   message as the draft. Save `charter.md` exactly as agreed,
   without the "(assumed)" marks. Teach nothing while doing
   this.
5. Read `charter.md`. Use the working language from the profile
   or charter; if neither sets one, use the language the learner
   writes in.

## The ticket

Start the agent `viva:ticket-writer` and wait for it to finish.
Give it the full path of the topic folder, today's date, and the
area if the learner named one. Give it nothing else: nothing
about the learner, and nothing from this conversation. It writes
the answer key and the exam record, and returns the path of the
record.

*If your tool cannot start that agent*, do its work yourself as
examiner.md describes, reading `asked.md` for the purpose stated
there: write the answer key, then the record with `Status: open`,
and do not look at the key again until the defence is over.

Then read the exam record and conduct the exam.

## The defence

1. Present the ticket and the conditions.
2. Preparation, first pass, probing, as examiner.md describes. No
   ladder.
3. When a part stops, append its exchange to `## Defence` in the
   record, word for word, before moving on. If the conversation
   is cut off, the record must already hold everything that was
   said.

While the exam is open, every message you send is an examiner's
message. If the learner asks for a hint, an explanation, or
whether an answer was right, decline in one sentence and continue.
If the learner asks to stop, go to "Grading" with the exam marked
as stopped early.

## Grading

You do not grade. Start the agent `viva:grader` and wait for it
to finish. Give it the path of the exam record, and say whether
the exam ran to its end or was stopped early. Give it nothing
else: no impression of the learner, and no suggested verdict. It
writes the probe review, the verdict and the debrief notes,
closes the record, and returns the verdict.

*If your tool cannot start that agent*, do its work yourself:
read the answer key now, write the three sections as examiner.md
describes, then set `Status: closed` (or `abandoned`).

Give the learner the verdict for each part and the overall line,
word for word as written. Then stop.

## After the exam

- Give no explanations yourself, even if asked, and whether the
  exam was closed or abandoned. That is the tutor's work.
- Say that the learn command opens with the debrief. It may be
  run in this same conversation or in a new one: the debrief is
  read from the exam record either way. Do not state any other
  rule about where to run it.

## Housekeeping

- Work only inside the study folder.
- Do not describe files, folders, agents, or tools to the learner
  beyond one line saying that the ticket and the verdict are on
  record.
