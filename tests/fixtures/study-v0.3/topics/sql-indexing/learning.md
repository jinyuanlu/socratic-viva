# Learning state: SQL indexing
- Updated: 2026-11-15
- Target level: 4
- Diagnostic: done

## Skill map
| Area | Level | Checks at next level | Last tested | Next review |
|---|---|---|---|---|
| 1. B-tree structure and what a lookup, range scan and ordered scan cost | 3 | 0 | 2026-11-15 | 2026-11-16 |
| 2. Reading EXPLAIN (ANALYZE, BUFFERS): scan types, estimated vs actual rows, where the time goes | 3 | 0 | 2026-11-15 | |
| 3. Selectivity, statistics and the planner's choice between sequential, index and bitmap scans | 1 | 1 | 2026-11-15 | 2026-11-16 |
| 4. Multicolumn indexes: column order, equality vs range predicates, serving ORDER BY and LIMIT | 2 | 0 | 2026-11-15 | |
| 5. Index-only scans, covering indexes (INCLUDE) and the visibility map | 2 | 0 | 2026-11-15 | |
| 6. Partial and expression indexes, and predicates that prevent index use | 2 | 0 | 2026-11-15 | |
| 7. Indexes for joins and aggregations: nested loop, hash and merge joins, GROUP BY, DISTINCT | 1 | 1 | 2026-11-15 | 2026-11-16 |
| 8. Non-B-tree index types: GIN, GiST, BRIN, hash, and when each fits | 2 | 0 | 2026-11-15 | |
| 9. Costs and upkeep: write overhead, HOT updates, bloat, unused and redundant indexes, CREATE INDEX CONCURRENTLY | 1 | 0 |  | |

## Misconceptions
- [resolved 2026-11-15] 3. Selectivity, statistics and the planner's choice between sequential, index and bitmap scans: thinks the planner's row estimate comes from the index, and that a wrong estimate means the index is out of date
- [open] 5. Index-only scans, covering indexes (INCLUDE) and the visibility map: thinks heap fetches in an index-only scan come from a stale or bloated index and that REINDEX brings them down
- [open] 6. Partial and expression indexes, and predicates that prevent index use: thinks an expression index on (paid_at::date) can be created on a timestamptz column as written
- [open] 8. Non-B-tree index types: GIN, GiST, BRIN, hash, and when each fits: thinks a BRIN index makes inserts slower than the B-tree it replaces, and sees no read penalty

## Sessions
- 2026-11-15: Charter agreed and diagnostic run over five questions; all nine areas placed, three misconceptions opened; began area 3 on the 41 s nested-loop plan, where a fourth misconception appeared and was resolved, then moved to the join choice in area 7 and the cost of a single-value index scan in area 1.

## Debriefed exams
