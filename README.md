# Socratic Viva

**Learn Socratically. Certify by viva.**

A two-mode skill set for self-improvement, built for agent
harnesses (Claude Code skills and compatible systems). It pairs
the two halves of how deep learning actually gets verified:

1. **Learning — the Socratic tutor.** You are taught by questions,
   never handed answers: diagnostic placement, a skill map with
   levels earned only on demonstrated performance, one question at
   a time, spaced review. (Integrated whole from Jane Street's
   open-source `socratic-tutor` skill — see `vendor/`.)
2. **Assessment — the Landau exam.** Modelled on the Landau-school
   oral examination tradition (MIPT): draw a random ticket,
   prepare, defend, and be probed until the edge of your
   understanding is found. No hints, no ladder. Every ticket
   carries a foundations question — *why* is this true — because
   recognition-level knowledge cannot answer one.

The two modes are kept strictly separate, and that separation is
the design: practice scores can overfit to the tutor, so mastery
is only ever claimed on the strength of a held-out exam the tutor
did not coach. A level says "performed in practice". A verdict
says "certified".

## Commands

| Command | Mode | What it does |
|---|---|---|
| `/viva:learn [topic] [subskill]` | Learn | Tutoring: diagnostic on a new topic, weakest-first resume, spaced review built in; opens with the debrief if an exam verdict is waiting |
| `/viva:exam [topic]` | Exam | Draw a ticket and sit the oral exam; the verdict is written to the record |
| `/viva:status [topic]` | Meta | Skill map, exam history — practised vs certified, kept separate |

Full specification: [COMMANDS.md](COMMANDS.md).

## Install

This repo is a plugin marketplace for both Codex and Claude Code;
the plugin itself lives in `plugins/socratic-viva/` and carries a
manifest for each system (`.codex-plugin/plugin.json`,
`.claude-plugin/plugin.json`) over one shared skill.

- **Codex** — Add plugin marketplace: source `jinyuanlu/socratic-viva`,
  git ref `main`, sparse paths empty. Then install **socratic-viva**.
- **Claude Code** — `/plugin marketplace add jinyuanlu/socratic-viva`,
  then install **socratic-viva**.

## Files

- `plugins/socratic-viva/skills/socratic-viva/SKILL.md` — the
  two-mode system and the rules binding it
- `plugins/socratic-viva/skills/socratic-viva/landau-exam.md` —
  the examiner protocol (our design)
- `plugins/socratic-viva/skills/socratic-viva/COMMANDS.md` — the
  command interface
- `plugins/socratic-viva/skills/socratic-viva/vendor/socratic-tutor-SKILL.md`
  — Jane Street's Socratic tutor, vendored verbatim (MIT,
  © Jane Street Group, LLC), from
  https://github.com/janestreet/agent_skills

## Why

Answers are free now; verified understanding is not. A tutor that
only teaches produces fluency that feels like knowledge. An exam
that only measures produces anxiety without growth. This set
chains them in the order institutions like ETH (graduate oral
exams) and the Landau school always used — learn by dialogue,
then defend before an examiner who owes you nothing — with the
train/test separation made explicit, because that separation is
what makes the certificate mean anything.

## License

MIT. The vendored tutor retains its original MIT license and
attribution.
