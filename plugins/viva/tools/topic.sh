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
#
# Folders are only ever moved whole. An interrupted commit or rename
# is finished by running the same command again; <root>/journal
# records each step.

set -u

die() { echo "topic.sh: $*" >&2; exit 1; }
usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }
today() { date +%Y-%m-%d; }
lower() { tr '[:upper:]' '[:lower:]'; }
trim() { sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }
# Replace file $1 with standard input, in place and byte for byte.
# (The "." keeps the trailing newlines that $(...) would drop.)
put() { new=$(cat; echo .) && [ "$new" != . ] && printf '%s' "${new%.}" > "$1"; }
# Refuse a folder name that is not a plain name.
plain() { case "$1" in ''|.|..|*/*|*'|'*) die "'$1' is not a folder name." ;; esac; }

title_of() { sed -n '1s/^#[[:space:]]*//p' "$1/charter.md" | trim; }
aliases_of() { sed -n 's/^- Also called:[[:space:]]*//p' "$1/charter.md" | tr ';' '\n' | trim; }
# Every name a topic answers to, lower case, one per line.
names_of() { { title_of "$1"; aliases_of "$1"; } | lower | sed '/^$/d'; }

# The lines of section "## $2" in file $1, without the heading.
section() {
  awk -v h="## $2" '{ l = $0; sub(/[ \t\r]+$/, "", l) }
    l == h { on = 1; next } /^## / { on = 0 } on' "$1"
}
# Top-level syllabus areas, without their numbers.
areas_of() { section "$1/charter.md" Syllabus | sed -n 's/^[0-9][0-9]*\.[[:space:]][[:space:]]*//p' | trim; }
# True if the syllabus has a second level (indented items, or 1.1 numbering).
two_level() { section "$1/charter.md" Syllabus | grep -Eq '^[[:space:]]+([0-9]|[-*+][[:space:]])|^[0-9]+\.[0-9]'; }
# Column $2 of the skill map of topic $1: the rows after the |---| row
# (after the first row, if the table has no |---| row).
map_col() {
  section "$1/learning.md" "Skill map" | awk -F'|' -v c="$2" '
    /^[ \t]*\|/ { n++; if (!sep && /-/ && /^[ \t\r|:-]+$/) sep = n; cell[n] = $(c + 1) }
    END { for (i = (sep ? sep : 1) + 1; i <= n; i++) print cell[i] }' | trim
}
rows_of() { map_col "$1" 1 | sed 's/^[0-9][0-9]*\.[[:space:]][[:space:]]*//'; }
levels_of() { map_col "$1" 2; }

status_of() { sed -n 's/^- Status:[[:space:]]*//p' "$1" | head -n 1 | trim; }
# True if $1 is an exam record: an existing file that is not an answer key.
# Callers loop over exams/[0-9]*.md, the top level only: exams/from-*/ is history.
is_record() { [ -f "$1" ] && case "$1" in *.key.md) false ;; esac; }
# The number of exam record $1, without leading zeros.
number_of() { basename "$1" | awk -F- '{ print $1 + 0 }'; }
debriefed_of() {
  [ -f "$1/learning.md" ] || return 0
  section "$1/learning.md" "Debriefed exams" | sed -n 's/^-[[:space:]]*\([0-9][0-9]*\).*/\1/p' | awk '{ print $1 + 0 }'
}
# The open exam records of every topic under root $1.
open_exams() {
  for f in "$1"/topics/*/exams/[0-9]*.md; do
    is_record "$f" && [ "$(status_of "$f")" = open ] && echo "$f"
  done
}
# Checksums of every file under folder $1, paths relative to it (not the macOS Finder's own file).
sums() {
  (cd "$1" 2>/dev/null || exit 0
   find . -type f ! -name .DS_Store | LC_ALL=C sort | while IFS= read -r f; do printf '%s %s\n' "$(cksum < "$f")" "$f"; done)
}

# The journal has one line per step: <stamp>|<state>|<operation>|<folder>|<folder>.
journal() { echo "$2|$3" >> "$1/journal" || die "cannot write $1/journal."; }
# The unfinished operation, if any: the last journal line, unless it is done or aborted.
pending() {
  [ -f "$1/journal" ] || return 0
  awk -F'|' '{ l = $0; s = $2 } END { if (NR && s != "done" && s != "aborted") print l }' "$1/journal"
}
# A date-time stamp not yet used in the journal or the archive of root $1.
new_stamp() {
  base=$(date +%Y%m%d-%H%M%S); s=$base; i=1
  while [ -e "$1/archive/$s" ] || grep -q "^$s|" "$1/journal" 2>/dev/null; do i=$((i + 1)); s="$base-$i"; done
  echo "$s"
}

# Print what is wrong with topic folder $1; status 1 if anything is.
# Lines starting "note:" are not errors. Call it inside $(...).
check_topic() {
  t=$1; bad=0
  fail() { echo "  $1"; bad=1; }
  [ -f "$t/charter.md" ] || { echo "  no charter.md"; return 1; }
  [ -n "$(title_of "$t")" ] || fail "charter.md has no title line"
  [ -n "$(areas_of "$t")" ] || fail "charter.md has no syllabus areas"
  if [ -f "$t/learning.md" ]; then
    if two_level "$t"; then
      echo "  note: two-level syllabus, skill-map rows not compared"
    elif [ "$(areas_of "$t")" != "$(rows_of "$t")" ]; then
      fail "skill-map rows differ from the syllabus areas (same names, same order, one row each)"
    fi
    levels_of "$t" | grep -qv '^[0-5]$' && fail "a level is not a number from 0 to 5"
    for n in $(debriefed_of "$t"); do
      found=no
      for f in "$t"/exams/[0-9]*.md; do
        is_record "$f" && [ "$(number_of "$f")" = "$n" ] && found=yes
      done
      [ $found = yes ] || fail "debriefed exam $n has no record"
    done
  fi
  for f in "$t"/exams/[0-9]*.md; do
    is_record "$f" || continue
    case "$(status_of "$f")" in
      open|closed|abandoned) ;;
      *) fail "$(basename "$f") has no valid status" ;;
    esac
    [ -f "${f%.md}.key.md" ] || echo "  note: $(basename "$f") has no answer key (made before keys existed)"
  done
  return $bad
}

# Names (lower case) of every topic under root $1, except folders $2 and $3.
other_names() {
  for t in "$1"/topics/*/; do
    t=${t%/}
    case "$t" in "$2"|"${3:-}") continue ;; esac
    [ -f "$t/charter.md" ] && names_of "$t" | LC_ALL=C sort -u
  done
}

check_root() {
  root=$1; bad=0
  [ -d "$root" ] || die "no study folder $root."
  for t in "$root"/topics/*/; do
    [ -d "$t" ] || continue
    out=$(check_topic "${t%/}") || bad=1
    [ -n "$out" ] && { echo "$(basename "$t"):"; echo "$out"; }
  done
  dup=$(other_names "$root" "" | LC_ALL=C sort | uniq -d)
  [ -n "$dup" ] && { echo "names used by more than one topic:"; echo "$dup" | sed 's/^/  /'; bad=1; }
  p=$(pending "$root")
  [ -n "$p" ] && { echo "unfinished operation: $p"; bad=1; }
  return $bad
}

# Refuse to move anything while an exam is open or an operation is unfinished.
guard_idle() {
  [ -d "$1/topics" ] || die "no study folder $1."
  o=$(open_exams "$1")
  [ -z "$o" ] || die "an exam is open ($o). Finish or close it first."
  p=$(pending "$1")
  [ -z "$p" ] || die "an earlier operation is unfinished ($p). Run the same command again to finish it, or abort."
  [ ! -e "$1/staging" ] || die "a staging folder already exists. Run commit or abort first."
}
# Refuse if one of the names $2 (one per line) belongs to a topic other than folders $3 and $4.
guard_names_free() {
  taken=$({ printf '%s\n' "$2" | lower | LC_ALL=C sort -u; other_names "$1" "$3" "${4:-}" | LC_ALL=C sort -u; } |
    LC_ALL=C sort | uniq -d | sed '/^$/d')
  [ -z "$taken" ] || die "already the name of another topic: $(echo "$taken" | tr '\n' ';')"
}
# Add name $2 to the "Also called" line of charter $1, unless it is there.
add_alias() {
  aliases_of "$(dirname "$1")" | lower | grep -Fxq -e "$(printf '%s' "$2" | lower)" && return 0
  if grep -q '^- Also called:' "$1"; then at=line; else at=top; fi
  A=$2 awk -v at=$at '
    at == "line" && /^- Also called:/ && !did { sub(/[ \t\r]*$/, ""); $0 = $0 ($0 ~ /:$/ ? " " : "; ") ENVIRON["A"]; did = 1 }
    { print }
    at == "top" && NR == 1 { print "- Also called: " ENVIRON["A"] }' "$1" | put "$1"
}
# Add the line "- <today>: $2" at the end of section "## Changes" of charter $1.
log_change() {
  L="- $(today): $2" awk '
    /^[ \t\r]*$/ { blank++; next }
    /^## / && on && !did { print ENVIRON["L"]; did = 1 }
    { for (; blank > 0; blank--) print ""; print }
    /^## / { on = ($0 ~ /^## Changes[ \t\r]*$/) }
    END { if (!did) { if (!on) print "\n## Changes"; print ENVIRON["L"] } }' "$1" | put "$1"
}
# Put title $2 on the heading line of file $1, keeping what stands before ": " ($3 if nothing does).
retitle() {
  [ -f "$1" ] || return 0
  T=$2 P=$3 awk 'NR == 1 && /^#/ { i = index($0, ": "); $0 = (i ? substr($0, 1, i + 1) : ENVIRON["P"]) ENVIRON["T"] }
    { print }' "$1" | put "$1"
}

cmd_rename() {
  [ $# -eq 4 ] || usage
  root=$1; old="$root/topics/$2"; new="$root/topics/$3"; title=$4
  plain "$2"; plain "$3"
  case "$title" in ''|*';'*) die "a title cannot be empty or contain ';'." ;; esac
  p=$(pending "$root")
  case "$p" in
    *"|started|rename|$2|$3") stamp=${p%%|*} ;;   # finishing an interrupted rename
    *)
      [ -f "$old/charter.md" ] || die "no topic folder $2."
      [ "$2" = "$3" ] || [ ! -e "$new" ] || die "a folder named $3 already exists."
      [ "$2" != "$3" ] || [ "$(title_of "$old")" != "$title" ] || die "nothing to rename."
      guard_idle "$root"
      guard_names_free "$root" "$title" "$old"
      stamp=$(new_stamp "$root"); journal "$root" "$stamp" "started|rename|$2|$3" ;;
  esac
  if [ -d "$old" ] && [ ! -e "$new" ]; then mv "$old" "$new" || die "cannot move $2."; fi
  c="$new/charter.md"; was=$(title_of "$new")
  grep -Fq -e "($2) to \"$title\" ($3)." "$c" || log_change "$c" "renamed from \"$was\" ($2) to \"$title\" ($3)."
  if [ "$was" != "$title" ]; then
    [ "$(printf '%s' "$was" | lower)" = "$(printf '%s' "$title" | lower)" ] || add_alias "$c" "$was"
    retitle "$new/learning.md" "$title" "# Learning state: "
    retitle "$new/asked.md" "$title" "# Asked: "
    T=$title awk 'NR == 1 { $0 = "# " ENVIRON["T"] } { print }' "$c" | put "$c"   # last: it marks the rename as made
  fi
  journal "$root" "$stamp" "done|rename|$2|$3"
  echo "renamed: $2 -> $3"
}

cmd_stage() {
  [ $# -eq 3 ] || usage
  root=$1; src="$root/topics/$2"; tgt="$root/topics/$3"; st="$root/staging/topics/$3"; from="$st/exams/from-$2"
  plain "$2"; plain "$3"
  [ -f "$src/charter.md" ] || die "no topic folder $2."
  [ -f "$tgt/charter.md" ] || die "no topic folder $3."
  [ "$2" != "$3" ] || die "source and target are the same topic."
  guard_idle "$root"
  [ ! -e "$tgt/exams/from-$2" ] || die "$3 already holds exams from a topic named $2. Rename $2 first."
  listed=$(debriefed_of "$src")
  for f in "$src"/exams/[0-9]*.md; do
    is_record "$f" || continue
    echo "$listed" | grep -qx "$(number_of "$f")" || die "exam $(basename "$f") of $2 has not been debriefed. Debrief it first, so that nothing is left pending."
  done
  stamp=$(new_stamp "$root"); journal "$root" "$stamp" "staged|merge|$2|$3"
  mkdir -p "$root/staging/topics" && cp -Rp "$tgt" "$st" && mkdir -p "$from" || die "cannot build the staged copy. Run abort."
  if [ -d "$src/exams" ]; then cp -Rp "$src/exams/." "$from/" || die "cannot copy the exams of $2. Run abort."; fi
  cp -p "$src/charter.md" "$from/source-charter.md" || die "cannot copy the charter of $2. Run abort."
  if [ -f "$src/asked.md" ]; then
    { if [ -f "$tgt/asked.md" ]; then awk '{ print }' "$tgt/asked.md"; else printf '%s\n' "# Asked: $(title_of "$tgt")"; fi
      printf '%s\n' "- $(today) | merged | from \"$(title_of "$src")\" | the lines below keep that topic's area numbers"
      awk 'NR == 1 && /^#/ { next } NF' "$src/asked.md"; } > "$st/asked.md" || die "cannot write the staged asked.md. Run abort."
  fi
  # What commit compares against: both originals, and the exams that were copied in.
  sums "$src" > "$root/staging/sums-source"; sums "$tgt" > "$root/staging/sums-target"
  sums "$src/exams" > "$root/staging/sums-exams"
  echo "staged: $st"
  echo "Edit charter.md and learning.md in that folder, then run commit."
}

# Refuse the commit unless the files under $2 still have the checksums recorded in staging file $1.
unchanged() {
  [ "$(sums "$2" | grep -v ' \./source-charter\.md$')" = "$(cat "$root/staging/$1")" ] || die "$3 Nothing was moved."
}

cmd_commit() {
  [ $# -eq 3 ] || usage
  root=$1; src="$root/topics/$2"; tgt="$root/topics/$3"; st="$root/staging/topics/$3"
  p=$(pending "$root")
  case "$p" in *"|merge|$2|$3") ;; *) die "no merge of $2 into $3 is in progress." ;; esac
  stamp=${p%%|*}; state=${p#*|}; state=${state%%|*}; arch="$root/archive/$stamp/topics"
  if [ "$state" = staged ]; then
    o=$(open_exams "$root"); [ -z "$o" ] || die "an exam is open ($o). Nothing was moved."
    out=$(check_topic "$st") || { echo "$out"; die "the staged topic fails its checks. Nothing was moved."; }
    unchanged sums-exams "$st/exams/from-$2" "the merged-in exam files differ from the source's."
    unchanged sums-source "$src" "the topic $2 has changed since it was staged. Run abort, then stage again."
    unchanged sums-target "$tgt" "the topic $3 has changed since it was staged. Run abort, then stage again."
    names_of "$st" | grep -Fxq -e "$(title_of "$src" | lower)" ||
      die "the staged charter does not list \"$(title_of "$src")\" under 'Also called'. Nothing was moved."
    guard_names_free "$root" "$(names_of "$st")" "$src" "$tgt"
    mkdir -p "$arch" || die "cannot create $arch. Nothing was moved."
    journal "$root" "$stamp" "moving|merge|$2|$3"; state=moving
  fi
  # Each step is skipped if an earlier, interrupted run already made it.
  if [ "$state" = moving ]; then
    [ -e "$arch/$3" ] || mv "$tgt" "$arch/$3" || die "cannot move $3. Run commit again."
    journal "$root" "$stamp" "moved-target|merge|$2|$3"; state=moved-target
  fi
  if [ "$state" = moved-target ]; then
    [ -e "$arch/$2" ] || mv "$src" "$arch/$2" || die "cannot move $2. Run commit again."
    journal "$root" "$stamp" "moved-source|merge|$2|$3"; state=moved-source
  fi
  [ "$state" = moved-source ] || die "the journal state '$state' is not known."
  if [ -d "$st" ]; then mv "$st" "$tgt" || die "cannot move the staged topic into place. Run commit again."; fi
  if [ -d "$root/staging" ]; then mv "$root/staging" "$root/archive/$stamp/staging" || die "cannot archive the staging folder. Run commit again."; fi
  journal "$root" "$stamp" "done|merge|$2|$3"
  echo "merged: $2 -> $3. The two originals are in $arch/"
}

cmd_abort() {
  [ $# -eq 1 ] || usage
  root=$1; p=$(pending "$root")
  case "$p" in
    '') [ -e "$root/staging" ] || die "nothing is unfinished."
        stamp=$(new_stamp "$root"); p="$stamp|staged|merge||" ;;   # a staging folder the journal does not know
    *"|staged|merge|"*) stamp=${p%%|*} ;;
    *) die "folders have already been moved ($p). Run the same command again to finish it." ;;
  esac
  if [ -d "$root/staging" ]; then
    mkdir -p "$root/archive/$stamp" && mv "$root/staging" "$root/archive/$stamp/staging" || die "cannot archive the staging folder."
  fi
  journal "$root" "$stamp" "aborted|${p#*|staged|}"
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
