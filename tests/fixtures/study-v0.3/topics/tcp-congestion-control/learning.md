# Learning state: TCP congestion control
- Updated: 2026-11-15
- Target level: 4
- Diagnostic: done

## Skill map
| Area | Level | Checks at next level | Last tested | Next review |
|---|---|---|---|---|
| 1. The congestion window and the ACK clock: what limits how much a sender has in flight | 2 | 0 | 2026-11-15 | |
| 2. Slow start and congestion avoidance: window growth, ssthresh, restart after idle | 3 | 0 | 2026-11-15 | |
| 3. Loss detection and recovery: duplicate ACKs, SACK, fast retransmit, tail loss probes, retransmission timeouts | 2 | 0 | 2026-11-15 | 2026-11-16 |
| 4. RTT estimation and the retransmission timer: how they are computed, backoff, effect on tail latency | 2 | 1 | 2026-11-15 | 2026-11-16 |
| 5. Loss-based algorithms (Reno, CUBIC): behaviour and failure modes | 2 | 1 | 2026-11-15 | 2026-11-16 |
| 6. BBR: how a model-based algorithm differs, its trade-offs and fairness | 1 | 1 | 2026-11-15 | 2026-11-16 |
| 7. Queues on the path: buffer bloat, active queue management, ECN, pacing | 2 | 0 | 2026-11-15 | 2026-11-16 |
| 8. Telling apart congestion-limited, receiver-limited and application-limited flows | 2 | 0 | 2026-11-15 | 2026-11-16 |
| 9. Reading the evidence: ss and tcp_info fields, retransmit counters, packet captures | 3 | 0 | 2026-11-15 | 2026-11-16 |
| 10. Choosing and justifying a change: algorithm, initial window, buffers, queueing discipline, and their side effects | 1 | 1 | 2026-11-15 | 2026-11-16 |

## Misconceptions
- [resolved 2026-11-15] 3. Loss detection and recovery: thinks fast retransmit is a shorter timer that fires sooner than the regular retransmission timeout
- [open] 3. Loss detection and recovery: assumes every retransmission counted in ss follows a retransmission timer expiry

## Sessions
- 2026-11-15: Charter written and diagnostic run over all ten areas; placed at levels 1 to 3, with one open misconception about fast retransmit.
- 2026-11-15: Debrief of exam 001 begun; Part 1 (what caps the sender under a flat, loss-free queueing delay) retried correctly and re-tested from a new angle, no level change.
- 2026-11-15: Debrief of exam 001, Part 2: fast retransmit trigger restated correctly (three duplicate ACKs, timer as fallback), NewReno partial-ACK rule and recovery point explained, short-tail case predicted correctly; misconception resolved, no level change.
- 2026-11-15: Debrief of exam 001, Part 3: proposal rejected with correct reasons, minimum RTO (origin, purpose, owner, how to lower, side effects) explained, 600 ms outlier derived unaided as a doubled second timeout (one check for area 4); debrief complete.
- 2026-11-15: New work on area 5: explained unaided why a loss-based sender must fill the bottleneck buffer before it learns of congestion, and that it learns a round trip late (one check for area 5).
- 2026-11-15: New work on area 6: derived unaided the two measurements a model-based sender needs (minimum RTT, delivery rate) and named the freshness problem of both (one check for area 6); BBR's probing phases then introduced.
- 2026-11-15: Debrief of exam 002, Part 2: retry reached the drain-for-a-clean-RTT-sample mechanism but not the model; BBR's two estimates, their use, expiry and the cost of the drain explained; re-test (an application-limited flow shows no dip) predicted correctly, no level change.
- 2026-11-15: Debrief of exam 002, Part 3: retry identified 65,535 as the 16-bit maximum and argued against a slow reader; window scaling, its trace in ss, and the evidence excluding loss explained; re-test (a congestion-limited connection) read correctly, no level change; a new wrong assumption about retransmissions appeared; debrief complete.
- 2026-11-15: Area 3 revisited after the timer assumption returned: worked out from a 22-segment example that duplicate ACKs arrive long before the timer and withdrew the assumption, but could not recall the duplicate-ACK threshold; misconception kept open until an independent check.
- 2026-11-15: New work on area 10: predicted unaided that doubling the send buffer does nothing for a congestion-limited transfer, with the evidence for it (one check for area 10).

## Debriefed exams
- 001
- 002
