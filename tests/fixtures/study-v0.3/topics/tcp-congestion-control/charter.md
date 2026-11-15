# TCP congestion control
- Goal: Debug production latency: tell whether congestion control is the cause, then pick a change and justify it
- Deadline: none
- Kind: mixed
- Standard: Senior backend engineer. Given a symptom and evidence, diagnoses whether and how congestion control causes the latency, chooses a change, justifies it, and predicts its side effects, all under follow-up questions.
- Working language: English
- Exam conditions: closed-book; text

## Syllabus
1. The congestion window and the ACK clock: what limits how much a sender has in flight
2. Slow start and congestion avoidance: window growth, ssthresh, restart after idle
3. Loss detection and recovery: duplicate ACKs, SACK, fast retransmit, tail loss probes, retransmission timeouts
4. RTT estimation and the retransmission timer: how they are computed, backoff, effect on tail latency
5. Loss-based algorithms (Reno, CUBIC): behaviour and failure modes
6. BBR: how a model-based algorithm differs, its trade-offs and fairness
7. Queues on the path: buffer bloat, active queue management, ECN, pacing
8. Telling apart congestion-limited, receiver-limited and application-limited flows
9. Reading the evidence: ss and tcp_info fields, retransmit counters, packet captures
10. Choosing and justifying a change: algorithm, initial window, buffers, queueing discipline, and their side effects

## Out of scope
- QUIC and other non-TCP transports
- Connection setup and TLS handshakes
- Kernel implementation details and writing a congestion control module
- Latency causes outside the transport (garbage collection, locks, DNS), beyond ruling them out
- Operating systems other than Linux

## Sources
- none yet

## Changes
- 2026-11-15: charter created
