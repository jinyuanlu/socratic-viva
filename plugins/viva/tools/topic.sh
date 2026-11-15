#!/bin/sh
# Viva topic tool. Moves topic folders and checks their invariants.
# It makes no judgement about content and never deletes anything:
# what it replaces goes to <root>/archive/.
#
#   topic.sh check      <topic-folder>
#   topic.sh check-root <root>
#   topic.sh rename     <root> <old-folder> <new-folder> <new title>
#   topic.sh stage      <root> <source-folder> <target-folder>
#   topic.sh commit     <root> <source-folder> <target-folder>
#   topic.sh abort      <root>
#
# <root> is the study folder; folder names are names under <root>/topics.
# Exit status: 0 ok, 1 a check failed or the operation was refused,
# 2 wrong usage.

set -u

die() { echo "topic.sh: $*" >&2; exit 1; }
usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }
today() { date +%Y-%m-%d; }
lower() { tr '[:upper:]' '[:lower:]'; }
trim() { sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }

title_of() { sed -n '1s/^# *//p' "$1/charter.md" | trim; }
aliases_of() {
  sed -n 's/^- Also called:[[:space:]]*//p' "$1/charter.md" | tr ';' '\n' | trim | sed '/^$/d'
}
# Every name a topic answers to, lower case, one per line.
names_of() { { title_of "$1"; aliases_of "$1"; } | lower; }

# The lines of section "## $2" in file $1, without the heading.
section() {
  awk -v h="## $2" '$0 == h { on = 1; next } /^## / { on = 0 } on' "$1"
}
areas_of() { section "$1/charter.md" Syllabus | sed -n 's/^[0-9][0-9]*\.[[:space:]]*//p' | trim; }
rows_of() {
  section "$1/learning.md" "Skill map" | grep '^|' | sed '1,2d' |
    awk -F'|' '{ print $2 }' | trim | sed 's/^[0-9][0-9]*\.[[:space:]]*//'
}
levels_of() {
  section "$1/learning.md" "Skill map" | grep '^|' | sed '1,2d' | awk -F'|' '{ print $3 }' | trim
}
status_of() { sed -n 's/^- Status:[[:space:]]*//p' "$1" | head -n 1; }
# Exam records of a topic: top level of exams/ only, answer keys excluded.
records_of() {
  for f in "$1"/exams/*.md; do
    [ -f "$f" ] || continue
    case "$f" in *.key.md) continue ;; esac
    echo "$f"
  done
}
number_of() { basename "$1" | sed 's/-.*//'; }
debriefed_of() {
  [ -f "$1/learning.md" ] || return 0
  section "$1/learning.md" "Debriefed exams" | sed -n 's/^-[[:space:]]*\([0-9][0-9]*\).*/\1/p'
}
open_exams() {
  for t in "$1"/topics/*/; do
    [ -d "$t" ] || continue
    for f in $(records_of "${t%/}"); do
      [ "$(status_of "$f")" = open ] && echo "$f"
    done
  done
}
# Checksums of every file under folder $1, paths relative to it.
sums() { (cd "$1" && find . -type f | LC_ALL=C sort | while read -r f; do printf '%s %s\n' "$(cksum < "$f")" "$f"; done); }

journal() { echo "$2|$3" >> "$1/journal"; }
# The unfinished operation, if any: "<stamp>|<state>|<op and arguments>".
pending() {
  [ -f "$1/journal" ] || return 0
  awk -F'|' '{ s[$1] = $2; d[$1] = $3 FS $4 FS $5; o[n++] = $1 }
    END { for (i = 0; i < n; i++) if (s[o[i]] != "done" && s[o[i]] != "aborted" && !seen[o[i]]++) print o[i] FS s[o[i]] FS d[o[i]] }' "$1/journal" | tail -n 1
}

check_topic() {
  t=$1; bad=0
  fail() { echo "  $1"; bad=1; }
  [ -f "$t/charter.md" ] || { echo "  no charter.md"; return 1; }
  [ -n "$(title_of "$t")" ] || fail "charter.md has no title line"
  [ -n "$(areas_of "$t")" ] || fail "charter.md has no syllabus areas"
  if [ -f "$t/learning.md" ]; then
    if section "$t/charter.md" Syllabus | grep -q '^[[:space:]][[:space:]]*[0-9]'; then
      echo "  note: two-level syllabus, skill-map rows not compared"
    else
      a=$(areas_of "$t"); r=$(rows_of "$t")
      [ "$a" = "$r" ] || fail "skill-map rows differ from the syllabus areas"
    fi
    levels_of "$t" | grep -qv '^[0-5]$' && fail "a level is not a number from 0 to 5"
    for n in $(debriefed_of "$t"); do
      ls "$t"/exams/"$n"-*.md > /dev/null 2>&1 || fail "debriefed exam $n has no record"
    done
  fi
  for f in $(records_of "$t"); do
    case "$(status_of "$f")" in
      open|closed|abandoned) ;;
      *) fail "$(basename "$f") has no valid status" ;;
    esac
    [ -f "${f%.md}.key.md" ] || echo "  note: $(basename "$f") has no answer key (made before keys existed)"
  done
  return $bad
}

check_root() {
  root=$1; bad=0
  for t in "$root"/topics/*/; do
    [ -d "$t" ] || continue
    out=$(check_topic "${t%/}") || bad=1
    [ -n "$out" ] && { echo "$(basename "$t"):"; echo "$out"; }
  done
  dup=$(for t in "$root"/topics/*/; do [ -f "$t/charter.md" ] && names_of "${t%/}"; done | LC_ALL=C sort | uniq -d)
  [ -n "$dup" ] && { echo "names used by more than one topic:"; echo "$dup" | sed 's/^/  /'; bad=1; }
  p=$(pending "$root")
  [ -n "$p" ] && { echo "unfinished operation: $p"; bad=1; }
  return $bad
}

# Refuse to move anything while an exam is open or an operation is unfinished.
guard_idle() {
  o=$(open_exams "$1")
  [ -z "$o" ] || die "an exam is open ($o). Finish or close it first."
  p=$(pending "$1")
  [ -z "$p" ] || die "an earlier operation is unfinished ($p). Run commit or abort first."
}
# Fail if name $2 (any case) is already a title or alias of a topic other than $3 or $4.
guard_name_free() {
  want=$(printf '%s' "$2" | lower)
  for t in "$1"/topics/*/; do
    t=${t%/}
    [ "$t" = "$3" ] || [ "$t" = "${4:-}" ] || [ ! -f "$t/charter.md" ] && continue
    names_of "$t" | grep -Fxq "$want" && die "the name '$2' already belongs to the topic $(basename "$t")."
  done
  return 0
}
# Add name $2 to the "Also called" line of charter $1, unless it is there or is the title.
add_alias() {
  c=$1; name=$2; dir=$(dirname "$c")
  names_of "$dir" | grep -Fxq "$(printf '%s' "$name" | lower)" && return 0
  if grep -q '^- Also called:' "$c"; then
    awk -v n="$name" '/^- Also called:/ { print $0 "; " n; next } { print }' "$c" > "$c.tmp"
  else
    awk -v n="$name" 'NR == 1 { print; print "- Also called: " n; next } { print }' "$c" > "$c.tmp"
  fi
  mv "$c.tmp" "$c"
}
log_change() {
  grep -q '^## Changes' "$1" || printf '\n## Changes\n' >> "$1"
  echo "- $(today): $2" >> "$1"
}

cmd_rename() {
  [ $# -eq 4 ] || usage
  root=$1; old="$root/topics/$2"; new="$root/topics/$3"; title=$4
  [ -f "$old/charter.md" ] || die "no topic folder $2."
  [ ! -e "$new" ] || die "a folder named $3 already exists."
  guard_idle "$root"
  guard_name_free "$root" "$title" "$old"
  was=$(title_of "$old"); stamp=$(date +%Y%m%d-%H%M%S)
  journal "$root" "$stamp" "started|rename|$2|$3"
  mv "$old" "$new"
  for pair in "charter.md:# " "learning.md:# Learning state: " "asked.md:# Asked: "; do
    f="$new/${pair%%:*}"; prefix=${pair#*:}
    [ -f "$f" ] || continue
    awk -v l="$prefix$title" 'NR == 1 { print l; next } { print }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  done
  add_alias "$new/charter.md" "$was"
  log_change "$new/charter.md" "renamed from \"$was\" to \"$title\"."
  journal "$root" "$stamp" "done|rename|$2|$3"
  echo "renamed: $2 -> $3"
}

cmd_stage() {
  [ $# -eq 3 ] || usage
  root=$1; src="$root/topics/$2"; tgt="$root/topics/$3"; st="$root/staging/topics/$3"
  [ -f "$src/charter.md" ] || die "no topic folder $2."
  [ -f "$tgt/charter.md" ] || die "no topic folder $3."
  [ "$2" != "$3" ] || die "source and target are the same topic."
  guard_idle "$root"
  [ ! -e "$root/staging" ] || die "a staging folder already exists. Run commit or abort first."
  done_list=$(debriefed_of "$src")
  for f in $(records_of "$src"); do
    n=$(number_of "$f")
    echo "$done_list" | grep -qx "$n" || die "exam $n of $2 has not been debriefed. Debrief it first, so that nothing is left pending."
  done
  stamp=$(date +%Y%m%d-%H%M%S)
  journal "$root" "$stamp" "staged|merge|$2|$3"
  mkdir -p "$root/staging/topics"
  cp -R "$tgt" "$st"
  mkdir -p "$st/exams/from-$2"
  [ -d "$src/exams" ] && cp -R "$src/exams/." "$st/exams/from-$2/"
  cp "$src/charter.md" "$st/exams/from-$2/source-charter.md"
  if [ -f "$src/asked.md" ]; then
    [ -f "$st/asked.md" ] || echo "# Asked: $(title_of "$tgt")" > "$st/asked.md"
    echo "- $(today) | merged | from \"$(title_of "$src")\" | the lines below keep that topic's area numbers" >> "$st/asked.md"
    grep '^- ' "$src/asked.md" >> "$st/asked.md"
  fi
  if [ -d "$src/exams" ]; then sums "$src/exams" > "$root/staging/exam-sums"; else : > "$root/staging/exam-sums"; fi
  echo "$stamp" > "$root/staging/stamp"
  echo "staged: $st"
  echo "Edit charter.md and learning.md in that folder, then run commit."
}

cmd_commit() {
  [ $# -eq 3 ] || usage
  root=$1; src="$root/topics/$2"; tgt="$root/topics/$3"; st="$root/staging/topics/$3"
  [ -f "$root/staging/stamp" ] || die "nothing is staged."
  stamp=$(cat "$root/staging/stamp"); arch="$root/archive/$stamp/topics"
  state=$(pending "$root" | awk -F'|' '{ print $2 }')
  if [ "$state" = staged ]; then
    o=$(open_exams "$root"); [ -z "$o" ] || die "an exam is open ($o)."
    out=$(check_topic "$st") || { echo "$out"; die "the staged topic fails its checks. Nothing was moved."; }
    sums "$st/exams/from-$2" | grep -v ' \./source-charter\.md$' > "$root/staging/exam-sums.now"
    cmp -s "$root/staging/exam-sums" "$root/staging/exam-sums.now" ||
      die "the merged-in exam files differ from the source's. Nothing was moved."
    names_of "$st" | grep -Fxq "$(title_of "$src" | lower)" ||
      die "the staged charter does not list \"$(title_of "$src")\" under 'Also called'. Nothing was moved."
    for name in $(names_of "$st" | tr ' ' '\001'); do
      guard_name_free "$root" "$(printf '%s' "$name" | tr '\001' ' ')" "$src" "$tgt"
    done
    mkdir -p "$arch"
    mv "$tgt" "$arch/$3";  journal "$root" "$stamp" "moved-target|merge|$2|$3"; state=moved-target
  fi
  if [ "$state" = moved-target ]; then
    mv "$src" "$arch/$2";  journal "$root" "$stamp" "moved-source|merge|$2|$3"; state=moved-source
  fi
  if [ "$state" = moved-source ]; then
    mv "$st" "$tgt"
    mkdir -p "$root/archive/$stamp/staging" && mv "$root/staging"/* "$root/archive/$stamp/staging/" 2>/dev/null
    rmdir "$root/staging/topics" 2>/dev/null; rmdir "$root/staging"
    journal "$root" "$stamp" "done|merge|$2|$3"
    echo "merged: $2 -> $3. The two originals are in $root/archive/$stamp/topics/"
    return 0
  fi
  die "no merge of $2 into $3 is in progress."
}

cmd_abort() {
  [ $# -eq 1 ] || usage
  root=$1; p=$(pending "$root"); [ -n "$p" ] || die "nothing is unfinished."
  stamp=${p%%|*}; state=$(echo "$p" | awk -F'|' '{ print $2 }')
  [ "$state" = staged ] || die "the merge has already begun moving folders ($state). Run commit to finish it."
  mkdir -p "$root/archive/$stamp" && mv "$root/staging" "$root/archive/$stamp/staging"
  journal "$root" "$stamp" "aborted|merge||"
  echo "aborted. The staged copy is in $root/archive/$stamp/staging. No topic was changed."
}

[ $# -ge 1 ] || usage
cmd=$1; shift
case "$cmd" in
  check)      [ $# -eq 1 ] || usage; out=$(check_topic "$1"); rc=$?; [ -n "$out" ] && echo "$out"; [ $rc -eq 0 ] && echo "ok"; exit $rc ;;
  check-root) [ $# -eq 1 ] || usage; check_root "$1"; rc=$?; [ $rc -eq 0 ] && echo "ok"; exit $rc ;;
  rename)     cmd_rename "$@" ;;
  stage)      cmd_stage "$@" ;;
  commit)     cmd_commit "$@" ;;
  abort)      cmd_abort "$@" ;;
  *)          usage ;;
esac
