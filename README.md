# Socratic Viva

**Learn Socratically. Certify by viva.**

Socratic Viva is a personal learning system that runs inside an AI
coding agent (Claude Code, Codex, and compatible tools). You can
use it for any topic: a university course, a programming language,
a human language, a job interview, a book.

It has two modes, and it keeps them apart.

1. **Learn.** A tutor teaches you by asking questions, and does
   not hand you answers. It finds your level first, keeps a skill
   map, asks one question at a time, and brings old material back
   for review on a schedule.
2. **Exam.** An examiner gives you a ticket of three questions,
   lets you prepare, and then probes your answers until it finds
   where your understanding stops. It gives no hints. It writes a
   verdict for each part.

A *viva* (from Latin *viva voce*, "with the living voice") is an
oral examination.

## Why two modes

Answers are cheap now. Verified understanding is not.

If the same tutor both teaches you and grades you, your score
measures how well you learned the tutor's questions. So the exam
here is *held-out*: it is drawn from the syllabus, not from what
you practised, and the examiner is not allowed to read your
practice record. A practice level means "performed in practice".
Only an exam verdict means "certified".

## Install

**Claude Code**

    /plugin marketplace add jinyuanlu/socratic-viva
    /plugin install viva@socratic-viva

**Codex**: add this repository as a plugin marketplace (source
`jinyuanlu/socratic-viva`, git ref `master`), then install the
plugin **viva**.

## Use

| Command | What it does |
|---|---|
| `/viva:learn [topic] [area]` | A tutoring session. A new topic starts with a short interview about your goal, then a diagnostic. A known topic continues: exam debrief first, then reviews that are due, then your weakest areas. |
| `/viva:exam [topic] [area]` | Sit the exam. Run it in a new conversation. |
| `/viva:status [topic]` | Show what is practised and what is certified, as two separate lists. Changes nothing. |

The command names above are the Claude Code form. In other tools,
call the plugin's `learn`, `exam` and `status` skills in the way
that tool provides.

Examples:

    /viva:learn operating systems
    /viva:learn Spanish, I want to reach B1 for a move to Chile in June
    /viva:learn backend engineer interview, system design
    /viva:exam operating systems
    /viva:status

Write in any language. The tutor answers in the language you use,
unless you set another one.

### What each kind of topic looks like

| Topic | Learn | Exam ticket |
|---|---|---|
| Theory and concepts | Questions that make you predict, explain, and find the error | State a result, derive it, apply it to a new case |
| Problem-solving | Problems you solve while reasoning aloud; your real work is checked | Solve a new problem, defend the method, solve it again under a changed constraint |
| A human language | Practice in the target language, with explanations in your own | A speaking or writing task, the same content under a change of tense or register, an unprepared exchange |
| Interview preparation | Practice in the formats you expect, built on your real experience | A mock interview: answer, defend under follow-up, handle a changed requirement |

## The exam

Each ticket has three parts.

1. **Core**: a central idea or task of the topic.
2. **Foundations**: why it is true, or why it is done that way.
   Recognising a correct answer is not enough to pass this part.
3. **Transfer**: a case you have not seen.

The examiner follows your own claims deeper until each part stops
in one of three ways, and that is the verdict for the part:

- **Holds**: you defended it under probing.
- **Edge found at …**: solid up to a named point.
- **Fails at fundamentals**: the missing foundation is named.

There are no hints and no partial credit for confident wording.
Saying "I do not know beyond this point" at a real limit is better
than a guess that fails two questions later. After the verdict,
`/viva:learn` opens with a debrief, and the edges the exam found
become your study plan.

The name "Landau exam" refers to the physicist Lev Landau, whose
"theoretical minimum" examinations set a famously high standard.
The ticket format is the one used in oral examinations in many
universities, especially in the former Soviet Union. This project
borrows the idea. It does not reproduce any historical exam.

## Your data

Everything is stored as plain Markdown files on your own computer,
in `~/.viva` (or in the folder named by the environment variable
`VIVA_HOME`). You can read and edit the files, back them up, or
delete them.

    ~/.viva/
      profile.md               your preferences (optional)
      topics/<topic>/
        charter.md             goal, standard, syllabus
        learning.md            practice record
        asked.md               situations already used in practice
        exams/001-<date>.md    one record per exam, with its answer key

Your tool may ask for permission to read the plugin's files and to
read and write this folder. That is expected.

The plugin sends nothing anywhere. Your conversation is processed
by the AI tool you run it in, under that tool's own privacy terms.
These files describe what you know and do not know, so keep the
folder out of public repositories.

## How the separation is kept

- The practice record and the exam record are different files with
  different writers.
- An exam is the work of three roles. A **ticket writer** writes
  the ticket and an answer key before you see anything. A
  **conductor** runs the defence without seeing the key. A
  **grader** that took no part in the defence writes the verdict
  from the transcript and the key, and first checks the
  conductor's questions for hints.
- In Claude Code the ticket writer and the grader are separate
  agents. Each starts with an empty context and knows nothing of
  your tutoring or of the conversation.
- The answer key is fixed before the defence. The transcript is
  written down word for word. A closed exam is never edited.
- The examiner refuses to start in a conversation that already
  contains tutoring on the topic, and asks for a new one.
- Syllabus areas are picked by how recently they were examined,
  not by how well you are doing.
- The tutor keeps a list of the situations it has used. The
  ticket writer must avoid them, and must pick each question at
  random from a wide set of candidates, so that an exam does not
  repeat the practice by coincidence.

In Claude Code a small hook shipped with the plugin enforces the
file rules: the practice record cannot be opened while an exam is
open and never by the examining agents, the answer key cannot be
opened by the conductor, and a closed exam cannot be written. It
is a shell script and needs `sh` (on Windows, Git for Windows).
It acts only on files inside a study folder.

In other tools, and for anything the hook does not cover, these
are rules that a language model follows. They are not locks. See
the limits below.

## Limits

- **"Certified" is a personal record.** It is not a diploma, a
  licence, or an official test result, and no institution
  recognises it. A language-level verdict is an estimate against a
  published scale, not a score from that scale's official test.
- **The examiner is an AI model and can be wrong.** It can accept
  a wrong answer or reject a right one. For anything where an
  error is costly, such as medicine, law, or safety, check against
  authoritative sources and qualified people.
- **The separation depends on behaviour.** A model can break an
  instruction, and nothing stops you from looking things up during
  a closed-book exam. The record is worth as much as the honesty
  on both sides.
- **Only what can be said, written, or run is examined.** A text
  conversation cannot judge pronunciation, listening, or a
  physical skill.
- **An interview verdict is not a prediction.** It says how your
  answers held under probing, not what any employer will decide.

## Repository layout

- [plugins/viva/skills/](plugins/viva/skills/): the three commands:
  [learn](plugins/viva/skills/learn/SKILL.md),
  [exam](plugins/viva/skills/exam/SKILL.md),
  [status](plugins/viva/skills/status/SKILL.md)
- [plugins/viva/protocol/examiner.md](plugins/viva/protocol/examiner.md):
  the examiner protocol
- [plugins/viva/agents/](plugins/viva/agents/ticket-writer.md): the
  [ticket writer](plugins/viva/agents/ticket-writer.md) and the
  [grader](plugins/viva/agents/grader.md)
- [plugins/viva/hooks/guard.sh](plugins/viva/hooks/guard.sh): the
  hook that enforces the file rules
- [plugins/viva/protocol/domains.md](plugins/viva/protocol/domains.md):
  how the method applies to each kind of topic
- [plugins/viva/protocol/state.md](plugins/viva/protocol/state.md):
  the files, their formats, and who may write each one
- [plugins/viva/vendor/socratic-tutor/](plugins/viva/vendor/socratic-tutor/README.md):
  the tutor method, copied unchanged from Jane Street's
  [agent_skills](https://github.com/janestreet/agent_skills)
- [scripts/check.py](scripts/check.py): checks manifests, skill
  headers, links, and the vendored file. Run `python3 scripts/check.py`.

## Contributing

Issues and pull requests are welcome, in clear and simple English
if possible, so that readers everywhere can follow. Please be
respectful. Run `python3 scripts/check.py` before you send a
change.

## Credits and licence

The tutoring method is the `socratic-tutor` skill by Jane Street
Group, LLC, used under the MIT licence and included unchanged.
Socratic Viva is an independent project and is not affiliated with
or endorsed by Jane Street, Anthropic, or OpenAI.

[MIT](LICENSE).
