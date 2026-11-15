#!/bin/sh
# Viva guard: a PreToolUse hook. It enforces the file rules of
# protocol/state.md for files inside a Viva study folder and ignores
# everything else. Exit 2 denies the tool call; exit 0 lets it pass.
#
#   1. learning.md is sealed while its topic has an open exam, and is
#      always closed to the ticket writer and the grader.
#   2. An answer key (exams/*.key.md) is readable only by the ticket
#      writer and the grader until its exam is closed or abandoned.
#   3. A closed or abandoned exam, and its key, cannot be written.
#   4. A copy of learning.md under <root>/archive or <root>/staging
#      is sealed while any topic of that study folder has an open exam.
#
# Read, Write, Edit and Grep are checked exactly, by path. Bash is
# checked by the text of the command, which is a best effort.

input=$(cat)
case "$input" in
  *learning.md*|*exams*|*.key.md*|*'"Grep"'*|*'"viva:'*) ;;
  *) exit 0 ;;
esac

field() {
  printf '%s' "$input" |
    sed -nE 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p' |
    head -n 1 | sed -e 's/\\\\/\\/g' -e 's/\\\//\//g'
}

deny() {
  echo "Viva guard: $1" >&2
  exit 2
}

status_of() {
  [ -f "$1" ] && sed -n 's/^- Status:[[:space:]]*//p' "$1" | head -n 1
}

# True if the topic folder $1 has an exam whose status is open.
topic_open() {
  for f in "$1"/exams/*.md; do
    case "$f" in *.key.md) continue ;; esac
    [ "$(status_of "$f")" = "open" ] && return 0
  done
  return 1
}

# True if any topic under the study root $1 has an open exam.
root_open() {
  for t in "$1"/topics/*/; do
    topic_open "${t%/}" && return 0
  done
  return 1
}

# The study folder that holds path $1 in its archive/ or staging/
# folder, if there is one. Prints nothing otherwise.
holding_root() {
  for k in archive staging; do
    r=$1/
    while case "$r" in */$k/*) true ;; *) false ;; esac; do
      r=${r%/$k/*}
      [ -d "$r/topics" ] && { echo "$r"; return; }
    done
  done
}

tool=$(field tool_name)
agent=$(field agent_type)
case "$agent" in
  viva:ticket-writer|viva:grader) examiner=yes ;;
  *) examiner=no ;;
esac
case "$tool" in
  Write|Edit) writing=yes ;;
  *) writing=no ;;
esac

sealed="the practice record is sealed while an exam on this topic is open, and is never available to the examiner."
kept="this is a kept copy of a practice record. It is sealed while any exam in the study folder is open."

if [ "$tool" = "Bash" ]; then
  cmd=$(field command)
  root=${VIVA_HOME:-$HOME/.viva}
  if [ "$examiner" = yes ]; then
    case "$cmd" in
      *learning.md*|*/topics/*|*VIVA_HOME*|*.viva*|*"$root"*)
        deny "the examiner reaches the study folder with Read, Write, Edit and Glob only, not through the shell." ;;
    esac
    exit 0
  fi
  case "$cmd" in
    *learning.md*|*.key.md*)
      root_open "$root" &&
        deny "an exam is open. Use the Read, Write or Edit tool on the exact file, so that the file rules can be checked." ;;
  esac
  exit 0
fi

path=$(field file_path)
[ -n "$path" ] || path=$(field path)
[ -n "$path" ] || exit 0

case "$path" in
  */topics/*/learning.md)
    topic=${path%/learning.md}
    [ -f "$topic/charter.md" ] || exit 0
    [ "$examiner" = yes ] && deny "$sealed"
    topic_open "$topic" && deny "$sealed"
    held=$(holding_root "$topic")
    [ -n "$held" ] && root_open "$held" && deny "$kept"
    ;;
  */topics/*/exams/*.key.md)
    topic=${path%/exams/*}
    [ -f "$topic/charter.md" ] || exit 0
    status=$(status_of "${path%.key.md}.md")
    case "$status" in
      closed|abandoned)
        [ "$writing" = yes ] && deny "this exam is $status. Its answer key is a record and cannot be changed." ;;
      *)
        [ "$examiner" = yes ] || deny "the answer key is sealed until the verdict is written." ;;
    esac
    ;;
  */topics/*/exams/*.md)
    topic=${path%/exams/*}
    [ -f "$topic/charter.md" ] || exit 0
    # Everything merged in from another topic is history, charter copy included.
    case "$path" in */exams/from-*)
      [ "$writing" = yes ] && deny "this file was merged in from another topic. It is a record and cannot be changed." ;;
    esac
    status=$(status_of "$path")
    case "$status" in
      closed|abandoned)
        [ "$writing" = yes ] && deny "this exam is $status. It is a record and cannot be changed." ;;
    esac
    ;;
  *)
    # Grep over a folder: do not let a search read a sealed practice record.
    if [ "$tool" = "Grep" ] && [ -d "$path" ]; then
      if [ -f "$path/learning.md" ] && [ -f "$path/charter.md" ]; then
        [ "$examiner" = yes ] && deny "$sealed Search the exams folder or name the file."
        topic_open "$path" && deny "$sealed Search the exams folder or name the file."
      elif [ -d "$path/topics" ]; then
        [ "$examiner" = yes ] && deny "$sealed Search one topic's exams folder."
        root_open "$path" && deny "$sealed Search one topic's exams folder."
      fi
      # The same for a folder in the archive or in staging, which may hold copies.
      case "$path" in */exams|*/exams/*) held= ;; *) held=$(holding_root "$path") ;; esac
      if [ -n "$held" ]; then
        [ "$examiner" = yes ] && deny "$sealed"
        root_open "$held" && deny "$kept"
      fi
    fi
    ;;
esac
exit 0
