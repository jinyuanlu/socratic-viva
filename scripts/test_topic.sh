#!/bin/sh
# Tests for plugins/viva/tools/topic.sh. Self-contained: builds its
# fixtures in a temporary folder and removes it at the end.
#   sh scripts/test_topic.sh          (TEST_SH=bash to run the tool under another shell)
# Prints ok/FAIL per case; exit status 1 if any case failed.

tool="$(cd "$(dirname "$0")/.." && pwd)/plugins/viva/tools/topic.sh"
SH=${TEST_SH:-sh}
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
pass=0; failed=0; nroot=0

ok() { pass=$((pass + 1)); echo "ok   $1"; }
no() { failed=$((failed + 1)); echo "FAIL $1"; [ -f "$T/out" ] && sed 's/^/       | /' "$T/out"; }
# is <description> <command...>: the command must succeed.
is() { d=$1; shift; if "$@" > /dev/null 2>&1; then ok "$d"; else no "$d"; fi; }
# run <status> <description> <tool arguments...>: output is kept in $T/out.
run() {
  want=$1; d=$2; shift 2
  "$SH" "$tool" "$@" > "$T/out" 2>&1; got=$?
  if [ "$got" -eq "$want" ]; then ok "$d"; else no "$d (status $got, expected $want)"; fi
}
says() { if grep -q -e "$2" "$T/out"; then ok "$1"; else no "$1 (output lacks: $2)"; fi; }
same() { if diff -r "$2" "$3" > "$T/diff" 2>&1; then ok "$1"; else no "$1"; sed 's/^/       | /' "$T/diff"; fi; }
# same_exams <description> <a source's exams folder> <its from-* folder>: identical, plus the source charter.
same_exams() {
  nx=$((${nx:-0} + 1)); cp -Rp "$3" "$T/x$nx"
  if [ -f "$T/x$nx/source-charter.md" ]; then rm "$T/x$nx/source-charter.md"; same "$1" "$2" "$T/x$nx"; else no "$1 (no source-charter.md)"; fi
}
last() { tail -n 1 "$R/journal"; }
stamp() { last | cut -d'|' -f1; }

# A new, empty study folder in $R. Its path contains a space.
fresh() { nroot=$((nroot + 1)); R="$T/study folder $nroot"; mkdir -p "$R/topics"; }

# topic <folder> <title>: a complete, valid topic with three areas.
topic() {
  d="$R/topics/$1"; mkdir -p "$d/exams"
  cat > "$d/charter.md" <<EOF
# $2
- Goal: be able to explain it
- Kind: concepts
- Standard: explains to a peer
- Working language: English
- Exam conditions: closed-book; text

## Syllabus
1. $1 basics
2. $1 with spaces, and: punctuation
3. $1 advanced

## Out of scope
- everything else

## Changes
- 2026-01-01: created.
EOF
  cat > "$d/learning.md" <<EOF
# Learning state: $2
- Updated: 2026-11-15
- Target level: 4
- Diagnostic: done

## Skill map
| Area | Level | Checks at next level | Last tested | Next review |
|---|---|---|---|---|
| 1. $1 basics | 2 | 0 | 2026-11-15 | 2026-11-16 |
| 2. $1 with spaces, and: punctuation | 0 | 0 | | |
| 3. $1 advanced | 5 | 1 | 2026-11-15 | 2026-12-01 |

## Misconceptions
- [open] $1 basics: thinks X causes Y

## Sessions
- 2026-11-15: diagnostic.

## Debriefed exams
EOF
  cat > "$d/asked.md" <<EOF
# Asked: $2
- 2026-11-15 | area 1 | a situation of $1 | what happens next
EOF
}
# exam <folder> <NNN> <status> [nokey]: an exam record, with its key unless "nokey".
exam() {
  d="$R/topics/$1/exams"; mkdir -p "$d"
  printf '# Exam %s: %s\n- Date: 2026-02-01\n- Status: %s\n\n## Ticket\n1. Core: why?\n' "$2" "$1" "$3" > "$d/$2-2026-02-01.md"
  [ "${4:-}" = nokey ] || printf '# Answer key: exam %s\n\n## Part 1\n- Must contain: because\n' "$2" > "$d/$2-2026-02-01.key.md"
}
debrief() { echo "- $2" >> "$R/topics/$1/learning.md"; }
# edit <file> <awk program>: change a fixture file.
edit() { awk "$2" "$1" > "$T/edit" && cat "$T/edit" > "$1"; }
# What the model does to a staged topic $1: add the names $2 and one new area, in both files.
model_edit() {
  A=$2 edit "$1/charter.md" 'NR == 1 { print; print "- Also called: " ENVIRON["A"]; next } /^## Out of scope/ { print "4. merged area\n" } { print }'
  edit "$1/learning.md" '{ print } /^\| 3\./ { print "| 4. merged area | 1 | 0 | | |" }'
  echo "- 2026-11-15: merged." >> "$1/charter.md"
}
# Two topics, "src" debriefed with keys and "tgt", staged and edited, ready to commit.
staged_pair() {
  fresh; topic src "Source Topic"; topic tgt "Target Topic"
  exam src 001 closed; exam src 002 abandoned; debrief src 001; debrief src 002
  exam tgt 001 closed; debrief tgt 001
  cp -Rp "$R/topics" "$T/before-$nroot"
  "$SH" "$tool" stage "$R" src tgt > "$T/out" 2>&1 || no "setup: stage"
  ST="$R/staging/topics/tgt"
  model_edit "$ST" "Source Topic"
}
# Nothing has moved: both originals are as they were and the archive holds no topic.
unmoved() {
  same "$1: source untouched" "$T/before-$nroot/src" "$R/topics/src"
  same "$1: target untouched" "$T/before-$nroot/tgt" "$R/topics/tgt"
  is "$1: nothing in the archive" test ! -e "$R/archive"
}

echo "# check"
fresh; topic good "Good Topic"; G="$R/topics/good"
exam good 001 closed; debrief good 001
run 0 "a good topic passes" check "$G"
says "and says ok" '^ok$'
run 2 "no arguments is a usage error" check
run 2 "an unknown subcommand is a usage error" frobnicate "$R"
edit "$G/learning.md" '{ sub(/^\| [0-9]\. /, "| "); print }'
run 0 "rows without their numbers pass" check "$G"
edit "$G/learning.md" '{ sub(/^\|---\|---\|---\|---\|---\|$/, "| :--- | :-: | --- | --- | ---: |"); print }'
run 0 "a separator row with alignment marks passes" check "$G"
edit "$G/learning.md" '!/^\| :---/'
run 0 "a table without a separator row passes" check "$G"
exam good 002 closed nokey
run 0 "a missing answer key is not an error" check "$G"
says "but is noted" 'note: 002-2026-02-01.md has no answer key'

# broken <description> <expected message> <file under the topic> <awk program>
broken() {
  fresh; topic t "Some Topic"; exam t 001 closed; debrief t 001
  edit "$R/topics/t/$3" "$4"
  run 1 "check fails: $1" check "$R/topics/t"
  says "  and says why" "$2"
}
broken "no title" "no title line" charter.md 'NR > 1'
broken "no syllabus areas" "no syllabus areas" charter.md '!/^[0-9]\. /'
broken "a row is named differently" "rows differ" learning.md '{ sub(/t basics \|/, "t basic |"); print }'
broken "a row is missing" "rows differ" learning.md '!/^\| 2\./'
broken "an area has no row" "rows differ" charter.md '{ print } /^3\. / { print "4. one more" }'
broken "rows are in another order" "rows differ" learning.md '/^\| 1\./ { keep = $0; next } { print } /^\| 2\./ { print keep }'
broken "a level is 7" "not a number from 0 to 5" learning.md '{ sub(/basics \| 2 \|/, "basics | 7 |"); print }'
broken "a level is a word" "not a number from 0 to 5" learning.md '{ sub(/basics \| 2 \|/, "basics | high |"); print }'
broken "a debriefed exam has no record" "debriefed exam 7 has no record" learning.md '{ print } END { print "- 007" }'
broken "a record has no status" "has no valid status" exams/001-2026-02-01.md '!/^- Status:/'
broken "a record has an unknown status" "has no valid status" exams/001-2026-02-01.md '{ sub(/Status: closed/, "Status: finished"); print }'
fresh; mkdir -p "$R/topics/empty"
run 1 "check fails: no charter" check "$R/topics/empty"

fresh; topic two "Two Levels"
edit "$R/topics/two/charter.md" '{ print } /^1\. / { print "   1.1 first part\n   1.2 second part" }'
edit "$R/topics/two/learning.md" '{ print } /^\| 1\./ { print "| 1.1 first part | 1 | 0 | | |" }'
run 0 "a two-level syllabus passes" check "$R/topics/two"
says "with a note" 'note: two-level syllabus'

echo "# check-root"
fresh; topic a "Alpha"; topic b "Beta"
run 0 "two good topics pass" check-root "$R"
# A topic as v0.3 made it: no asked.md, no keys, no "Also called".
topic old "Old Shape"; rm "$R/topics/old/asked.md"; exam old 001 closed nokey; debrief old 001
mkdir -p "$R/topics/charter-only"; cp "$R/topics/a/charter.md" "$R/topics/charter-only/charter.md"
edit "$R/topics/charter-only/charter.md" 'NR == 1 { print "# Only a charter"; next } { print }'
run 0 "topics in v0.3 shape pass" check-root "$R"
edit "$R/topics/b/charter.md" 'NR == 1 { print; print "- Also called: second; ALPHA"; next } { print }'
run 1 "an alias equal to another topic's title is reported" check-root "$R"
says "by name" '^  alpha$'
edit "$R/topics/b/charter.md" '{ sub(/; ALPHA/, "; beta"); print }'
run 0 "a topic that repeats its own name is not a collision" check-root "$R"
edit "$R/topics/a/charter.md" 'NR == 1 { print; print "- Also called: Second"; next } { print }'
run 1 "an alias shared by two topics is reported" check-root "$R"
says "by name" '^  second$'
edit "$R/topics/a/learning.md" '{ sub(/\| 5 \|/, "| 9 |"); print }'
run 1 "a broken topic fails check-root" check-root "$R"
says "under its folder name" '^a:$'
run 1 "a missing study folder is refused" check-root "$R/nowhere"

echo "# rename"
fresh; topic "old-name" "Old Name"; topic other "Other Topic"
exam old-name 001 closed; debrief old-name 001; mkdir -p "$R/topics/old-name/exams/from-x"
echo "# Exam 001: x" > "$R/topics/old-name/exams/from-x/001-2026-01-01.md"
cp -Rp "$R/topics/old-name" "$T/renamed-before"
run 1 "refused: the new title is another topic's" rename "$R" old-name new-name "other topic"
run 1 "refused: the new folder exists" rename "$R" old-name other "Brand New"
run 1 "refused: no such topic" rename "$R" missing new-name "Brand New"
run 1 "refused: a path as folder name" rename "$R" old-name "../escape" "Brand New"
same "a refused rename changes nothing" "$T/renamed-before" "$R/topics/old-name"
is "and leaves no journal" test ! -e "$R/journal"
run 0 "rename succeeds" rename "$R" old-name new-name "New Name: second edition"
N="$R/topics/new-name"
is "the old folder is gone" test ! -e "$R/topics/old-name"
is "the charter has the new title" test "$(sed -n 1p "$N/charter.md")" = "# New Name: second edition"
is "learning.md has the new title" test "$(sed -n 1p "$N/learning.md")" = "# Learning state: New Name: second edition"
is "asked.md has the new title" test "$(sed -n 1p "$N/asked.md")" = "# Asked: New Name: second edition"
is "the old title is an alias" grep -qx -e "- Also called: Old Name" "$N/charter.md"
is "the change is logged under Changes" test "$(awk '/^## Changes/ { on = 1 } on' "$N/charter.md" | grep -c 'renamed from "Old Name" (old-name) to "New Name: second edition" (new-name)')" = 1
same "everything under exams/ is byte-identical" "$T/renamed-before/exams" "$N/exams"
is "the rest of learning.md is unchanged" test "$(sed 1d "$N/learning.md" | cksum)" = "$(sed 1d "$T/renamed-before/learning.md" | cksum)"
is "the journal says done" test "$(last | cut -d'|' -f2-)" = "done|rename|old-name|new-name"
run 0 "check-root passes after the rename" check-root "$R"
run 0 "a second rename" rename "$R" new-name third "Third"
is "extends the alias line" grep -qx -e "- Also called: Old Name; New Name: second edition" "$R/topics/third/charter.md"
run 0 "a rename of the title only" rename "$R" third third "Third Name"
is "keeps the folder" test "$(sed -n 1p "$R/topics/third/charter.md")" = "# Third Name"
run 1 "refused: nothing to rename" rename "$R" third third "Third Name"

fresh; topic a "Alpha"
edit "$R/topics/a/learning.md" 'NR == 1 { print "# Estado de aprendizaje: Alpha"; next } { print }'
edit "$R/topics/a/charter.md" '/^## Changes/ { skip = 1 } /^## / && !/^## Changes/ { skip = 0 } !skip'
printf '\n## Sources\n- a book\n' >> "$R/topics/a/charter.md"
run 0 "rename with a translated heading and no Changes section" rename "$R" a b "Beta"
is "keeps the heading's own words" test "$(sed -n 1p "$R/topics/b/learning.md")" = "# Estado de aprendizaje: Beta"
is "adds the Changes section" test "$(tail -n 2 "$R/topics/b/charter.md" | sed -n 1p)" = "## Changes"
edit "$R/topics/b/charter.md" '/^## / { hold = ($0 ~ /^## Sources/) } hold { held = held $0 "\n"; next } { print } END { printf "%s", held }'
run 0 "rename when Changes is not the last section" rename "$R" b c "Gamma"
is "logs inside the Changes section" test "$(awk '/^## Changes/ { on = 1; next } /^## / { on = 0 } on' "$R/topics/c/charter.md" | grep -c 'renamed from')" = 2
is "and keeps the section after it" test "$(tail -n 1 "$R/topics/c/charter.md")" = "- a book"

fresh; topic a "Alpha"   # an interrupted rename: journal started, folder moved, titles not yet written
echo "20260101-000000|started|rename|a|b" > "$R/journal"; mv "$R/topics/a" "$R/topics/b"
run 1 "an interrupted rename is reported" check-root "$R"
says "as unfinished" 'unfinished operation: 20260101-000000|started|rename|a|b'
run 1 "another operation is refused meanwhile" rename "$R" b c "Gamma"
run 0 "the same rename, run again, finishes it" rename "$R" a b "Beta"
is "with the new title" test "$(sed -n 1p "$R/topics/b/learning.md")" = "# Learning state: Beta"
is "and the old title as alias" grep -qx -e "- Also called: Alpha" "$R/topics/b/charter.md"
run 0 "check-root passes afterwards" check-root "$R"

echo "# merge"
staged_pair
is "stage prints the staged folder" grep -q "^staged: $R/staging/topics/tgt$" "$T/out"
run 0 "commit succeeds" commit "$R" src tgt
M="$R/topics/tgt"; A="$R/archive/$(stamp)/topics"
is "the source folder is gone from topics" test ! -e "$R/topics/src"
same_exams "the source's exams are byte-identical under exams/from-src" "$T/before-$nroot/src/exams" "$M/exams/from-src"
is "the source's charter lies beside them" cmp "$T/before-$nroot/src/charter.md" "$M/exams/from-src/source-charter.md"
same "the archived source is byte-identical to the original" "$T/before-$nroot/src" "$A/src"
same "the archived target is byte-identical to the original" "$T/before-$nroot/tgt" "$A/tgt"
is "the target's own exams are unchanged" cmp "$T/before-$nroot/tgt/exams/001-2026-02-01.md" "$M/exams/001-2026-02-01.md"
is "the target's asked lines come first, unchanged" test "$(sed -n 1,2p "$M/asked.md" | cksum)" = "$(cksum < "$T/before-$nroot/tgt/asked.md")"
is "then one marker line" test "$(grep -c '| merged | from "Source Topic" |' "$M/asked.md")" = 1
is "then the source's asked lines, verbatim" test "$(tail -n 1 "$M/asked.md")" = "$(tail -n 1 "$T/before-$nroot/src/asked.md")"
is "asked.md has four lines" test "$(wc -l < "$M/asked.md" | tr -d ' ')" = 4
run 0 "the merged topic passes check" check "$M"
run 0 "check-root passes" check-root "$R"
is "the journal says done" test "$(last | cut -d'|' -f2-)" = "done|merge|src|tgt"
is "the staging folder is gone" test ! -e "$R/staging"
run 1 "a second commit is refused" commit "$R" src tgt
run 1 "abort has nothing to do" abort "$R"

echo "# commit refused"
staged_pair; edit "$ST/charter.md" '!/^- Also called:/'
run 1 "refused: the staged charter lacks the source's title" commit "$R" src tgt
says "  and says so" "Also called"
unmoved "no alias"
model_edit "$ST" "source topic" > /dev/null 2>&1; edit "$ST/charter.md" '!/^4\. merged area/ || !seen++'
edit "$ST/learning.md" '!/^\| 4\. merged area/ || !seen++'
run 0 "after the alias is added (in any case) commit succeeds" commit "$R" src tgt

staged_pair; echo "tampered" >> "$ST/exams/from-src/001-2026-02-01.md"
run 1 "refused: a merged-in exam record was altered" commit "$R" src tgt
says "  and says so" "merged-in exam files differ"
unmoved "altered record"
staged_pair; echo "tampered" >> "$ST/exams/from-src/002-2026-02-01.key.md"
run 1 "refused: a merged-in answer key was altered" commit "$R" src tgt
unmoved "altered key"
staged_pair; mv "$ST/exams/from-src/002-2026-02-01.md" "$ST/exams/from-src/003-2026-02-01.md"
run 1 "refused: a merged-in exam record was renumbered" commit "$R" src tgt
unmoved "renumbered record"
staged_pair; edit "$ST/learning.md" '!/^\| 4\./'
run 1 "refused: the staged topic fails its checks" commit "$R" src tgt
says "  and says which" "rows differ"
unmoved "failed check"
staged_pair; topic third "Third"; edit "$ST/charter.md" '{ sub(/^- Also called: Source Topic/, "- Also called: Source Topic; THIRD"); print }'
run 1 "refused: a staged alias is another topic's name" commit "$R" src tgt
says "  and names it" "third"
unmoved "alias collision"
staged_pair; echo "- 2026-11-15: one more session." >> "$R/topics/tgt/learning.md"
cp -Rp "$R/topics/tgt/learning.md" "$T/before-$nroot/tgt/learning.md"
run 1 "refused: the target changed after staging" commit "$R" src tgt
unmoved "changed target"
staged_pair; topic third "Third"; exam third 001 open
run 1 "refused: an exam was opened after staging" commit "$R" src tgt
unmoved "open exam"
staged_pair
run 1 "refused: commit names another pair" commit "$R" tgt src
unmoved "wrong pair"

echo "# chained merge"
fresh; topic a "Topic A"; topic b "Topic B"; topic c "Topic C"
exam a 001 closed; debrief a 001; exam b 001 abandoned; debrief b 001
cp -Rp "$R/topics" "$T/chain"
run 0 "stage a into b" stage "$R" a b
model_edit "$R/staging/topics/b" "Topic A"
run 0 "commit a into b" commit "$R" a b
run 0 "stage b into c (in the same second)" stage "$R" b c
model_edit "$R/staging/topics/c" "Topic B; Topic A"
run 0 "commit b into c" commit "$R" b c
C="$R/topics/c/exams"
same_exams "A's records are unchanged under c/exams/from-b/from-a" "$T/chain/a/exams" "$C/from-b/from-a"
is "A's records are there" cmp "$T/chain/a/exams/001-2026-02-01.md" "$C/from-b/from-a/001-2026-02-01.md"
is "A's key is there" cmp "$T/chain/a/exams/001-2026-02-01.key.md" "$C/from-b/from-a/001-2026-02-01.key.md"
is "A's charter is there" cmp "$T/chain/a/charter.md" "$C/from-b/from-a/source-charter.md"
is "B's record is there" cmp "$T/chain/b/exams/001-2026-02-01.md" "$C/from-b/001-2026-02-01.md"
is "B's charter is the one it had after the first merge" grep -qx -e "- Also called: Topic A" "$C/from-b/source-charter.md"
is "the two merges have separate archive folders" test "$(ls "$R/archive" | wc -l | tr -d ' ')" = 2
is "only c is left" test "$(ls "$R/topics")" = c
run 0 "check-root passes" check-root "$R"
topic a "Topic A again"; exam a 001 closed; debrief a 001; topic b "Topic B again"
run 0 "a new topic with an old folder name can be merged elsewhere" stage "$R" a b
run 0 "abort it" abort "$R"
mkdir -p "$R/topics/b/exams/from-a"
run 1 "refused: the target already has exams/from-<source>" stage "$R" a b

echo "# interrupted merge"
staged_pair
same "after stage the source is intact" "$T/before-$nroot/src" "$R/topics/src"
same "after stage the target is intact" "$T/before-$nroot/tgt" "$R/topics/tgt"
run 1 "check-root reports the unfinished operation" check-root "$R"
says "by its journal line" 'unfinished operation: .*|staged|merge|src|tgt'
run 1 "a second stage is refused" stage "$R" src tgt
run 1 "a rename is refused" rename "$R" src other "Other"
S=$(stamp)
run 0 "abort recovers" abort "$R"
same "abort: source untouched" "$T/before-$nroot/src" "$R/topics/src"
same "abort: target untouched" "$T/before-$nroot/tgt" "$R/topics/tgt"
is "abort: no topic in the archive" test ! -e "$R/archive/$S/topics"
is "the staged copy is kept in the archive" test -f "$R/archive/$S/staging/topics/tgt/charter.md"
is "the journal says aborted" test "$(last | cut -d'|' -f2-)" = "aborted|merge|src|tgt"
run 0 "check-root passes after abort" check-root "$R"
run 0 "the merge can be staged again" stage "$R" src tgt
model_edit "$R/staging/topics/tgt" "Source Topic"
run 0 "and committed" commit "$R" src tgt

# done_right <description>: the merge in $R is complete and correct.
done_right() {
  same "$1: archived source identical" "$T/before-$nroot/src" "$R/archive/$S/topics/src"
  same "$1: archived target identical" "$T/before-$nroot/tgt" "$R/archive/$S/topics/tgt"
  same_exams "$1: merged-in exams identical" "$T/before-$nroot/src/exams" "$R/topics/tgt/exams/from-src"
  is "$1: journal done" test "$(last | cut -d'|' -f2-)" = "done|merge|src|tgt"
  is "$1: staging gone" test ! -e "$R/staging"
  is "$1: source gone from topics" test ! -e "$R/topics/src"
  run 0 "$1: check-root passes" check-root "$R"
}

staged_pair; S=$(stamp)   # stopped after the first move, before its marker was written
echo "$S|moving|merge|src|tgt" >> "$R/journal"; mkdir -p "$R/archive/$S/topics"; mv "$R/topics/tgt" "$R/archive/$S/topics/tgt"
run 1 "after the first move, abort is refused" abort "$R"
run 1 "and check-root reports it" check-root "$R"
run 0 "commit, run again, completes the merge" commit "$R" src tgt
done_right "re-run after move 1"

staged_pair; S=$(stamp)   # stopped after the first move and its marker
printf '%s\n' "$S|moving|merge|src|tgt" "$S|moved-target|merge|src|tgt" >> "$R/journal"
mkdir -p "$R/archive/$S/topics"; mv "$R/topics/tgt" "$R/archive/$S/topics/tgt"
run 0 "commit completes after the marker moved-target" commit "$R" src tgt
done_right "re-run after marker 1"

staged_pair; S=$(stamp)   # stopped after both originals were moved
printf '%s\n' "$S|moving|merge|src|tgt" "$S|moved-target|merge|src|tgt" "$S|moved-source|merge|src|tgt" >> "$R/journal"
mkdir -p "$R/archive/$S/topics"; mv "$R/topics/tgt" "$R/archive/$S/topics/tgt"; mv "$R/topics/src" "$R/archive/$S/topics/src"
run 0 "commit completes after the marker moved-source" commit "$R" src tgt
done_right "re-run after marker 2"

staged_pair; S=$(stamp)   # stopped after the staged folder went into place
printf '%s\n' "$S|moving|merge|src|tgt" "$S|moved-target|merge|src|tgt" "$S|moved-source|merge|src|tgt" >> "$R/journal"
mkdir -p "$R/archive/$S/topics"; mv "$R/topics/tgt" "$R/archive/$S/topics/tgt"; mv "$R/topics/src" "$R/archive/$S/topics/src"
mv "$R/staging/topics/tgt" "$R/topics/tgt"
run 0 "commit completes after the last move" commit "$R" src tgt
done_right "re-run after move 3"

fresh; topic a "Alpha"; topic b "Beta"; mkdir -p "$R/staging/topics/b"   # a staging folder the journal does not know
run 1 "a stray staging folder blocks stage" stage "$R" a b
run 0 "abort clears it into the archive" abort "$R"
run 0 "then stage works" stage "$R" a b

echo "# refusals"
fresh; topic a "Alpha"; topic b "Beta"; topic c "Gamma"; exam c 001 open
cp -Rp "$R/topics" "$T/open-before"
run 1 "stage refused while an unrelated topic's exam is open" stage "$R" a b
says "  and names the exam" "an exam is open"
run 1 "rename refused while an unrelated topic's exam is open" rename "$R" a z "Zeta"
same "nothing changed" "$T/open-before" "$R/topics"
is "nothing was staged" test ! -e "$R/staging"
is "nothing was journalled" test ! -e "$R/journal"
fresh; topic a "Alpha"; topic b "Beta"; exam a 001 open
run 1 "stage refused while the source's exam is open" stage "$R" a b
fresh; topic a "Alpha"; topic b "Beta"; exam a 001 closed; exam a 002 abandoned; debrief a 001
run 1 "stage refused: the source has an undebriefed abandoned exam" stage "$R" a b
says "  and names it" "002-2026-02-01.md of a has not been debriefed"
debrief a 002; edit "$R/topics/a/learning.md" '!/^- 001$/'
run 1 "stage refused: the source has an undebriefed closed exam" stage "$R" a b
is "nothing was staged" test ! -e "$R/staging"
echo "- 1" >> "$R/topics/a/learning.md"
run 0 "stage accepts a debriefed list written without zeros" stage "$R" a b
fresh; topic a "Alpha"; topic b "Beta"; exam b 001 closed
run 0 "an undebriefed exam of the target does not block the merge" stage "$R" a b
fresh; topic a "Alpha"; topic b "Beta"
run 1 "stage refused: source and target are the same" stage "$R" a a
run 1 "stage refused: no such source" stage "$R" nope b
run 2 "stage with too few arguments is a usage error" stage "$R" a

echo "# other scripts, spaces"
fresh; topic "日本語" "日本語 の勉強"; topic "japonés" "Japonés para viajar"; topic "operating-systems" "Operating Systems"
exam "japonés" 001 closed; debrief "japonés" 001
run 0 "check-root passes with non-ASCII folders and titles" check-root "$R"
cp -Rp "$R/topics" "$T/intl"
run 0 "stage japonés into 日本語" stage "$R" "japonés" "日本語"
model_edit "$R/staging/topics/日本語" "Japonés para viajar"
run 0 "commit japonés into 日本語" commit "$R" "japonés" "日本語"
is "the record is under exams/from-japonés" cmp "$T/intl/japonés/exams/001-2026-02-01.md" "$R/topics/日本語/exams/from-japonés/001-2026-02-01.md"
same "the archived source is identical" "$T/intl/japonés" "$R/archive/$(stamp)/topics/japonés"
run 0 "rename 日本語 to 中文 with a title with spaces" rename "$R" "日本語" "中文" "中文 学习 计划"
is "the title is written" test "$(sed -n 1p "$R/topics/中文/learning.md")" = "# Learning state: 中文 学习 计划"
is "both old names are aliases" grep -qx -e "- Also called: Japonés para viajar; 日本語 の勉強" "$R/topics/中文/charter.md"
run 1 "a title that is another topic's, in other letter case, is refused" rename "$R" "中文" x "OPERATING systems"
run 1 "an alias in a non-ASCII script cannot be taken by another topic" rename "$R" operating-systems os "日本語 の勉強"
run 0 "check-root passes at the end" check-root "$R"

rm -f "$T/out"
echo
echo "passed: $pass   failed: $failed"
[ "$failed" -eq 0 ]
