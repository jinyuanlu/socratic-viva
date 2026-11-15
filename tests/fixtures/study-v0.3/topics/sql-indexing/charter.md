# SQL indexing
- Goal: tune slow PostgreSQL queries
- Deadline: none
- Kind: problem-solving
- Standard: experienced analytics engineer: given a slow query and its plan, finds the cause, chooses and justifies an index or rewrite, and names its costs
- Working language: English
- Exam conditions: closed-book; text

## Syllabus
1. B-tree structure and what a lookup, range scan and ordered scan cost
2. Reading EXPLAIN (ANALYZE, BUFFERS): scan types, estimated vs actual rows, where the time goes
3. Selectivity, statistics and the planner's choice between sequential, index and bitmap scans
4. Multicolumn indexes: column order, equality vs range predicates, serving ORDER BY and LIMIT
5. Index-only scans, covering indexes (INCLUDE) and the visibility map
6. Partial and expression indexes, and predicates that prevent index use
7. Indexes for joins and aggregations: nested loop, hash and merge joins, GROUP BY, DISTINCT
8. Non-B-tree index types: GIN, GiST, BRIN, hash, and when each fits
9. Costs and upkeep: write overhead, HOT updates, bloat, unused and redundant indexes, CREATE INDEX CONCURRENTLY

## Out of scope
- Server and hardware configuration tuning (memory settings, storage, connection pooling)
- Table partitioning, replication and sharding
- Schema design and query rewriting, except where it decides whether an index can be used
- Other database engines

## Sources
- None given

## Changes
- 2026-11-15: charter created
