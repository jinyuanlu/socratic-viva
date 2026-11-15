#!/bin/sh
# Tests for plugins/viva/hooks/guard.sh. Self-contained: builds two
# study folders in a temporary folder and feeds the hook the JSON
# that Claude Code sends before a tool call.
#   sh scripts/test_guard.sh          (TEST_SH=bash to run the hook under another shell)
# Prints ok/FAIL per case; exit status 1 if any case failed.

hook=${GUARD:-"$(cd "$(dirname "$0")/.." && pwd)/plugins/viva/hooks/guard.sh"}
SH=${TEST_SH:-sh}
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
pass=0; failed=0
DENY=2; ALLOW=0

# g <expected status> <description> <json>: run the hook with VIVA_HOME=$V.
g() {
  printf '%s' "$3" | HOME="$T/home dir" VIVA_HOME="$V" "$SH" "$hook" > /dev/null 2> "$T/err"; got=$?
  if [ "$got" -eq "$1" ]; then pass=$((pass + 1)); echo "ok   $2"
  else failed=$((failed + 1)); echo "FAIL $2 (status $got, expected $1)"; fi
}
# The JSON of a tool call. $3, if given, is the agent type.
agent() { [ -n "${1:-}" ] && printf ',"agent_type":"%s"' "$1"; }
file() { printf '{"session_id":"s","hook_event_name":"PreToolUse"%s,"tool_name":"%s","tool_input":{"file_path":"%s","content":"x"}}' "$(agent "${3:-}")" "$1" "$2"; }
grep_in() { printf '{"hook_event_name":"PreToolUse"%s,"tool_name":"Grep","tool_input":{"pattern":"level","path":"%s"}}' "$(agent "${2:-}")" "$1"; }
bash_of() { printf '{"hook_event_name":"PreToolUse"%s,"tool_name":"Bash","tool_input":{"command":"%s"}}' "$(agent "${2:-}")" "$1"; }
# rw <expected for Read> <expected for Write and Edit> <description> <path> [agent]
rw() {
  g "$1" "Read  $3" "$(file Read "$4" "${5:-}")"
  g "$2" "Write $3" "$(file Write "$4" "${5:-}")"
  g "$2" "Edit  $3" "$(file Edit "$4" "${5:-}")"
}

# topic <root> <folder>: a topic with a charter and a practice record.
topic() { mkdir -p "$1/topics/$2/exams"; echo "# $2" > "$1/topics/$2/charter.md"; echo "# Learning state: $2" > "$1/topics/$2/learning.md"; }
# exam <exams folder> <NNN> <status>: a record and its key.
exam() {
  mkdir -p "$1"
  printf '# Exam %s\n- Date: 2026-02-01\n- Status: %s\n' "$2" "$3" > "$1/$2-2026-02-01.md"
  echo "# Answer key: exam $2" > "$1/$2-2026-02-01.key.md"
}

# Two study folders, alike except that only "open" has open exams.
for name in open quiet; do
  r="$T/home dir/$name"
  topic "$r" calm; exam "$r/topics/calm/exams" 001 closed; exam "$r/topics/calm/exams" 002 abandoned
  exam "$r/topics/calm/exams/from-src" 001 closed; echo "# src" > "$r/topics/calm/exams/from-src/source-charter.md"
  exam "$r/topics/calm/exams/from-src/from-older" 001 abandoned
  topic "$r" busy; exam "$r/topics/busy/exams" 001 closed
  topic "$r" "日本語"; exam "$r/topics/日本語/exams" 001 closed
  topic "$r/archive/20260101-000000" gone; exam "$r/archive/20260101-000000/topics/gone/exams" 001 closed
  topic "$r/archive/20260101-000000" archive
  topic "$r/archive/20260102-000000/staging" dropped
  topic "$r/staging" calm
  mkdir -p "$r/archive/20260101-000000/topics/bare"; echo x > "$r/archive/20260101-000000/topics/bare/learning.md"
done
O="$T/home dir/open"; Q="$T/home dir/quiet"
exam "$O/topics/busy/exams" 002 open; exam "$O/topics/日本語/exams" 002 open
echo "# Answer key: exam 009" > "$Q/topics/calm/exams/009-2026-03-01.key.md"   # a key whose record is not written yet
mkdir -p "$T/elsewhere/topics/x/exams" "$T/plain"
echo x > "$T/elsewhere/topics/x/learning.md"; printf -- '- Status: closed\n' > "$T/elsewhere/topics/x/exams/001-2026-02-01.md"
echo x > "$T/elsewhere/topics/x/exams/001-2026-02-01.key.md"; echo x > "$T/plain/learning.md"

echo "# the practice record"
V=$O
rw $DENY $DENY "learning.md of a topic with an open exam" "$O/topics/busy/learning.md"
rw $ALLOW $ALLOW "learning.md of another topic meanwhile" "$O/topics/calm/learning.md"
rw $DENY $DENY "learning.md, open exam, non-ASCII topic name" "$O/topics/日本語/learning.md"
rw $DENY $DENY "learning.md, open exam, as another agent" "$O/topics/busy/learning.md" "general-purpose"
V=$Q
rw $ALLOW $ALLOW "learning.md when no exam is open" "$Q/topics/busy/learning.md"
rw $ALLOW $ALLOW "learning.md, non-ASCII topic name, no exam open" "$Q/topics/日本語/learning.md"
rw $DENY $DENY "learning.md by the grader, no exam open" "$Q/topics/calm/learning.md" "viva:grader"
rw $DENY $DENY "learning.md by the ticket writer, no exam open" "$Q/topics/calm/learning.md" "viva:ticket-writer"
rw $ALLOW $ALLOW "learning.md by another agent, no exam open" "$Q/topics/calm/learning.md" "general-purpose"
g $ALLOW "Read  charter.md by the grader" "$(file Read "$Q/topics/calm/charter.md" viva:grader)"
g $ALLOW "Read  asked.md by the ticket writer" "$(file Read "$Q/topics/calm/asked.md" viva:ticket-writer)"
g $DENY "Read  learning.md with JSON-escaped slashes" "$(file Read "$(printf '%s' "$O/topics/busy/learning.md" | sed 's|/|\\/|g')")"

echo "# answer keys"
V=$O
rw $DENY $DENY "key of an open exam, by the conductor" "$O/topics/busy/exams/002-2026-02-01.key.md"
rw $ALLOW $ALLOW "key of an open exam, by the grader" "$O/topics/busy/exams/002-2026-02-01.key.md" "viva:grader"
rw $ALLOW $ALLOW "key of an open exam, by the ticket writer" "$O/topics/busy/exams/002-2026-02-01.key.md" "viva:ticket-writer"
rw $DENY $DENY "key of an open exam, non-ASCII topic name" "$O/topics/日本語/exams/002-2026-02-01.key.md"
rw $ALLOW $DENY "key of a closed exam" "$O/topics/busy/exams/001-2026-02-01.key.md"
V=$Q
rw $ALLOW $DENY "key of a closed exam, no exam open" "$Q/topics/calm/exams/001-2026-02-01.key.md"
rw $ALLOW $DENY "key of an abandoned exam" "$Q/topics/calm/exams/002-2026-02-01.key.md"
rw $ALLOW $DENY "key of a closed exam, by the grader" "$Q/topics/calm/exams/001-2026-02-01.key.md" "viva:grader"
rw $ALLOW $DENY "key of a closed exam, by the ticket writer" "$Q/topics/calm/exams/001-2026-02-01.key.md" "viva:ticket-writer"
rw $DENY $DENY "key whose record does not exist yet, by the conductor" "$Q/topics/calm/exams/009-2026-03-01.key.md"
rw $ALLOW $ALLOW "key whose record does not exist yet, by the ticket writer" "$Q/topics/calm/exams/009-2026-03-01.key.md" "viva:ticket-writer"

echo "# exam records"
V=$O
rw $ALLOW $ALLOW "record of an open exam" "$O/topics/busy/exams/002-2026-02-01.md"
rw $ALLOW $ALLOW "record of an open exam, by the grader" "$O/topics/busy/exams/002-2026-02-01.md" "viva:grader"
rw $ALLOW $DENY "record of a closed exam" "$O/topics/busy/exams/001-2026-02-01.md"
V=$Q
rw $ALLOW $DENY "record of a closed exam, no exam open" "$Q/topics/calm/exams/001-2026-02-01.md"
rw $ALLOW $DENY "record of an abandoned exam" "$Q/topics/calm/exams/002-2026-02-01.md"
rw $ALLOW $DENY "record of a closed exam, by the grader" "$Q/topics/calm/exams/001-2026-02-01.md" "viva:grader"
rw $ALLOW $DENY "record of a closed exam, non-ASCII topic name" "$Q/topics/日本語/exams/001-2026-02-01.md"
rw $ALLOW $ALLOW "record that does not exist yet" "$Q/topics/calm/exams/003-2026-03-01.md"

echo "# records merged in from another topic"
rw $ALLOW $DENY "merged-in closed record" "$Q/topics/calm/exams/from-src/001-2026-02-01.md"
rw $ALLOW $DENY "merged-in closed record, by the ticket writer" "$Q/topics/calm/exams/from-src/001-2026-02-01.md" "viva:ticket-writer"
rw $ALLOW $DENY "key of a merged-in closed record" "$Q/topics/calm/exams/from-src/001-2026-02-01.key.md"
rw $ALLOW $DENY "key of a merged-in closed record, by the grader" "$Q/topics/calm/exams/from-src/001-2026-02-01.key.md" "viva:grader"
rw $ALLOW $DENY "merged-in abandoned record, two merges deep" "$Q/topics/calm/exams/from-src/from-older/001-2026-02-01.md"
rw $ALLOW $DENY "its key" "$Q/topics/calm/exams/from-src/from-older/001-2026-02-01.key.md"
V=$O
rw $ALLOW $DENY "merged-in closed record while another topic's exam is open" "$O/topics/calm/exams/from-src/001-2026-02-01.md"
rw $ALLOW $DENY "its key" "$O/topics/calm/exams/from-src/001-2026-02-01.key.md"

echo "# kept copies of the practice record: archive and staging"
V=$O; A="$O/archive/20260101-000000"
rw $DENY $DENY "archived learning.md while an exam is open" "$A/topics/gone/learning.md"
rw $DENY $DENY "archived learning.md, as another agent" "$A/topics/gone/learning.md" "general-purpose"
rw $DENY $DENY "archived learning.md of a topic named archive" "$A/topics/archive/learning.md"
rw $DENY $DENY "learning.md of an aborted merge in the archive" "$O/archive/20260102-000000/staging/topics/dropped/learning.md"
rw $DENY $DENY "staged learning.md while an exam is open" "$O/staging/topics/calm/learning.md"
rw $ALLOW $ALLOW "archived charter.md while an exam is open" "$A/topics/gone/charter.md"
rw $ALLOW $ALLOW "archived learning.md without a charter beside it" "$A/topics/bare/learning.md"
rw $ALLOW $DENY "archived closed record" "$A/topics/gone/exams/001-2026-02-01.md"
V=$Q; A="$Q/archive/20260101-000000"
rw $ALLOW $ALLOW "archived learning.md when no exam is open" "$A/topics/gone/learning.md"
rw $ALLOW $ALLOW "staged learning.md when no exam is open" "$Q/staging/topics/calm/learning.md"
rw $DENY $DENY "archived learning.md by the grader" "$A/topics/gone/learning.md" "viva:grader"
rw $DENY $DENY "archived learning.md by the ticket writer" "$A/topics/gone/learning.md" "viva:ticket-writer"
rw $DENY $DENY "staged learning.md by the grader" "$Q/staging/topics/calm/learning.md" "viva:grader"
rw $DENY $DENY "learning.md of an aborted merge by the ticket writer" "$Q/archive/20260102-000000/staging/topics/dropped/learning.md" "viva:ticket-writer"

echo "# Grep"
V=$O
g $DENY "Grep a topic with an open exam" "$(grep_in "$O/topics/busy")"
g $DENY "Grep a non-ASCII topic with an open exam" "$(grep_in "$O/topics/日本語")"
g $ALLOW "Grep another topic meanwhile" "$(grep_in "$O/topics/calm")"
g $DENY "Grep the study folder while an exam is open" "$(grep_in "$O")"
g $DENY "Grep learning.md itself while its exam is open" "$(grep_in "$O/topics/busy/learning.md")"
g $ALLOW "Grep the exams folder of a topic with an open exam" "$(grep_in "$O/topics/busy/exams")"
g $DENY "Grep the archive while an exam is open" "$(grep_in "$O/archive")"
g $DENY "Grep an archived topic while an exam is open" "$(grep_in "$O/archive/20260101-000000/topics/gone")"
g $DENY "Grep the staging folder while an exam is open" "$(grep_in "$O/staging")"
g $ALLOW "Grep an archived exams folder while an exam is open" "$(grep_in "$O/archive/20260101-000000/topics/gone/exams")"
V=$Q
g $ALLOW "Grep a topic, no exam open" "$(grep_in "$Q/topics/busy")"
g $ALLOW "Grep the study folder, no exam open" "$(grep_in "$Q")"
g $ALLOW "Grep the archive, no exam open" "$(grep_in "$Q/archive")"
g $ALLOW "Grep the staging folder, no exam open" "$(grep_in "$Q/staging/topics/calm")"
g $DENY "Grep a topic, by the grader" "$(grep_in "$Q/topics/calm" viva:grader)"
g $DENY "Grep the study folder, by the ticket writer" "$(grep_in "$Q" viva:ticket-writer)"
g $ALLOW "Grep a topic's exams folder, by the ticket writer" "$(grep_in "$Q/topics/calm/exams" viva:ticket-writer)"
g $DENY "Grep the archive, by the grader" "$(grep_in "$Q/archive" viva:grader)"
g $DENY "Grep an archived topic, by the ticket writer" "$(grep_in "$Q/archive/20260101-000000/topics/gone" viva:ticket-writer)"
g $DENY "Grep the staging folder, by the grader" "$(grep_in "$Q/staging" viva:grader)"
g $ALLOW "Grep with no path" '{"tool_name":"Grep","tool_input":{"pattern":"learning.md"}}'
g $ALLOW "Grep a folder that is not a study folder" "$(grep_in "$T/plain")"

echo "# Bash"
V=$O
g $DENY "a command that names learning.md while an exam is open" "$(bash_of "cat $O/topics/calm/learning.md")"
g $DENY "a command that names a key while an exam is open" "$(bash_of "cat 001-2026-02-01.key.md")"
g $DENY "a command that names an archived learning.md while an exam is open" "$(bash_of "cat $O/archive/20260101-000000/topics/gone/learning.md")"
g $ALLOW "a command that names neither" "$(bash_of "ls $O/topics")"
g $ALLOW "the topic tool, which names no sealed file" "$(bash_of "sh /plugin/tools/topic.sh stage \\\"$O\\\" \\\"calm\\\" \\\"busy\\\"")"
V=$Q
g $ALLOW "a command that names learning.md, no exam open" "$(bash_of "cat $Q/topics/calm/learning.md")"
g $ALLOW "a command that names a key, no exam open" "$(bash_of "cat 001-2026-02-01.key.md")"
g $DENY "the grader's shell: learning.md" "$(bash_of "cat learning.md" viva:grader)"
g $DENY "the grader's shell: a path under topics" "$(bash_of "ls /somewhere/topics/calm" viva:grader)"
g $DENY "the ticket writer's shell: VIVA_HOME" "$(bash_of 'ls $VIVA_HOME' viva:ticket-writer)"
g $DENY "the ticket writer's shell: .viva" "$(bash_of "ls ~/.viva" viva:ticket-writer)"
g $DENY "the grader's shell: the study folder by its path" "$(bash_of "ls $Q" viva:grader)"
g $ALLOW "the grader's shell: an unrelated command" "$(bash_of "date +%Y-%m-%d" viva:grader)"

echo "# files outside a study folder"
V=$O
rw $ALLOW $ALLOW "a file with no keyword in its path" "$T/plain/notes.md"
rw $ALLOW $ALLOW "a learning.md that is not in a topic folder" "$T/plain/learning.md"
rw $ALLOW $ALLOW "a learning.md in topics/x without a charter" "$T/elsewhere/topics/x/learning.md"
rw $ALLOW $ALLOW "the same, by the grader" "$T/elsewhere/topics/x/learning.md" "viva:grader"
rw $ALLOW $ALLOW "a closed record in topics/x/exams without a charter" "$T/elsewhere/topics/x/exams/001-2026-02-01.md"
rw $ALLOW $ALLOW "a key in topics/x/exams without a charter" "$T/elsewhere/topics/x/exams/001-2026-02-01.key.md"
g $ALLOW "empty input" ""
g $ALLOW "a tool call with no path" '{"tool_name":"Read","tool_input":{}}'

echo
echo "passed: $pass   failed: $failed"
[ "$failed" -eq 0 ]
