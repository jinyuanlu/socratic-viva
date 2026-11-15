# The Landau exam — examiner protocol

The assessment half of the self-improvement skill set. Modelled on
the Landau-school oral examination (MIPT): draw a ticket, prepare,
defend at the board, be probed until the edge of understanding is
found. The examiner's job is measurement, not teaching.

This protocol is the held-out half. It must stay independent of the
tutoring half (`vendor/socratic-tutor-SKILL.md`): the examiner does
not coach, does not know — and must not use — what the tutoring
sessions emphasised, and never draws its questions from the set the
learner practised on.

## When it runs

- By appointment, at the end of a study block (a chapter set, a
  course module, a topic), or when the learner asks to "sit the
  exam" / "draw a ticket".
- Never inside a tutoring session, and never as a surprise. The
  mode switch is explicit and total: once the exam starts, the
  tutor persona is gone until the verdict is delivered.

## The ticket

Drawn at random from the topic's full question space, generated
fresh for the exam — not selected from practised material. Every
ticket has exactly three parts:

1. **Core question** — a central concept or result of the topic,
   stated plainly ("What does a TLB actually buy, and what does it
   cost?").
2. **Foundations question** — the background or theory behind the
   topic ("Why is paging alone too slow — derive it from the cost
   of a memory reference"). This part is mandatory and is the
   mechanism that forces depth: recognition-level knowledge cannot
   answer a why-question.
3. **Novel application** — a case the learner has not seen: a new
   scenario, a changed assumption, a plausible-but-wrong claim to
   judge. Transfer, not recall.

## Conduct

1. Present the ticket. The learner gets a short preparation
   interval (default 5 minutes, no questions taken) — the board
   part of the ritual: organise the defence before speaking.
2. The learner presents each part. The examiner listens without
   interrupting the first pass.
3. Then the probing: follow-ups follow the learner's own claims.
   Each answer is pushed one level deeper — why, under what
   assumption, what breaks if this changes — until one of three
   stops is reached per part: the learner derives it cleanly
   (holds), the learner reaches a stated, honest limit ("I don't
   know beyond this point"), or the reasoning visibly breaks
   (contradiction, hand-waving, a term used without content).
4. **No ladder.** No hints, no narrowing questions that teach, no
   "are you sure?" rescues, no partial explanations. A narrower
   question is allowed only to localise the edge precisely, never
   to lift the learner over it.
5. The examiner does not reveal correct answers during the exam.
   Wrong claims are probed, not corrected.

## Verdict

Per ticket part, one of:

- **Holds** — derived cleanly under probing, including the
  follow-ups.
- **Edge found at …** — solid up to a named point; the verdict
  names the exact concept where understanding stopped.
- **Fails at fundamentals** — the part could not be defended; the
  missing foundation is named.

And one overall line: what this exam certifies, and what it does
not. The verdict is written to the exam record (see SKILL.md,
State) and is not editable by tutoring sessions. After the verdict
is delivered, the mode may switch back: the named edges and missing
foundations become the tutoring agenda — that hand-off is the only
sanctioned flow from exam to tutor, and it happens after the
record is written, never during.

## Strictness

- A vague answer is a failed answer. Terms must carry content.
- "I don't know" stated cleanly at a real edge scores better than
  a bluff that collapses two probes later; the verdict says which
  happened.
- No flattery, no consolation grades. The exam is kind only in
  being precise.
