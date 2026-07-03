#!/usr/bin/env bash
# worklog.sh — state machine for the infinite-working-skill.
# One JSON state file per task is the single source of truth for an autonomous,
# self-resuming work loop. A REGISTRY lets ONE generic resumer serve many tasks.
# All task-specific detail lives in the state file + a per-task PLAYBOOK; this
# script and the skill are program-agnostic. Portable bash + jq; epoch-seconds
# for heartbeat math so it does not depend on GNU vs BSD `date`.
set -uo pipefail

WL_CMD="${1:-}"; shift || true

now_epoch() { date +%s; }
now_iso()   { date -u +%Y-%m-%dT%H:%M:%SZ; }
die()       { echo "ERR: $*" >&2; exit 2; }
abspath()   { cd "$(dirname "$1")" && printf '%s/%s\n' "$(pwd)" "$(basename "$1")"; }

_write() { # _write <file> <jq-filter> [jq-args...]
  local f="$1"; shift; local filter="$1"; shift
  [ -f "$f" ] || die "no state file: $f"
  local tmp; tmp="$(mktemp)"
  if jq "$@" "$filter" "$f" > "$tmp"; then mv "$tmp" "$f"; else rm -f "$tmp"; die "jq write failed"; fi
}

# Registry of active tasks — resolved relative to this script so the skill is portable.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"      # .../infinite-working-skill/scripts
SKILL_DIR="$(dirname "$SCRIPT_DIR")"             # .../infinite-working-skill
REG="$SKILL_DIR/registry.tsv"                    # lines: <task_id>\t<abs_state_file>

case "$WL_CMD" in
  init) # init <file> <task_id> [title]
    f="${1:?file}"; id="${2:?task_id}"; title="${3:-$2}"
    if [ -f "$f" ]; then echo "EXISTS: $f (left as-is)"; exit 0; fi
    mkdir -p "$(dirname "$f")"
    jq -n --arg id "$id" --arg t "$title" \
      --argjson now "$(now_epoch)" --arg iso "$(now_iso)" '{
      task_id:$id, title:$t, status:"working", blocked_reason:null,
      created_at:$iso, last_heartbeat_epoch:$now, last_heartbeat:$iso,
      heartbeat_stale_seconds:1500, iteration:0,
      max_iterations:1000, consecutive_failures:0, max_consecutive_failures:4,
      checkpoint_every_seconds:0, checkpoint_action:null, last_checkpoint_epoch:$now,
      resumer_task_id:null, playbook_path:null, next_action:"", phases:[], ledger:[], notes:[]
    }' > "$f"
    echo "INIT: $f"
    ;;

  heartbeat) # heartbeat <file>  — run FIRST each turn; claims the turn, bumps iteration
    f="${1:?file}"
    _write "$f" '.last_heartbeat_epoch=$now | .last_heartbeat=$iso | .iteration += 1' \
      --argjson now "$(now_epoch)" --arg iso "$(now_iso)"
    read -r it mx hb < <(jq -r '[.iteration, .max_iterations, .last_heartbeat] | @tsv' "$f")
    echo "HEARTBEAT iter=$it/$mx at $hb"
    if [ "$it" -ge "$mx" ]; then echo "TRIP: max_iterations reached"; fi
    ;;

  set-status) # set-status <file> <working|blocked|done> [reason]
    f="${1:?file}"; st="${2:?status}"; reason="${3:-}"
    _write "$f" '.status=$s | .blocked_reason=(if $r=="" then null else $r end)' \
      --arg s "$st" --arg r "$reason"
    echo "STATUS: $st${reason:+ ($reason)}"
    ;;

  next) # next <file> <text...>
    f="${1:?file}"; shift; action="$*"
    _write "$f" '.next_action=$a' --arg a "$action"
    echo "NEXT: $action"
    ;;

  playbook-set) # playbook-set <file> <playbook_path>
    f="${1:?file}"; pb="${2:?playbook_path}"
    _write "$f" '.playbook_path=$p' --arg p "$pb"
    echo "PLAYBOOK: $pb"
    ;;

  ledger-add) # ledger-add <file> <unit>   (resets failure counter)
    f="${1:?file}"; item="${2:?unit}"
    _write "$f" 'if (.ledger|index($i)) then . else .ledger += [$i] end | .consecutive_failures=0' \
      --arg i "$item"
    echo "LEDGER+ $item (n=$(jq '.ledger|length' "$f"))"
    ;;

  ledger-has) # ledger-has <file> <unit>   exit 0=HAS, 1=MISSING  — the idempotency gate
    f="${1:?file}"; item="${2:?unit}"
    if jq -e --arg i "$item" '.ledger|index($i)' "$f" >/dev/null; then echo "HAS"; exit 0; else echo "MISSING"; exit 1; fi
    ;;

  fail) # fail <file> "<why>"   increments failure count; prints TRIP at the cap
    f="${1:?file}"; note="${2:-}"
    _write "$f" '.consecutive_failures += 1 | .notes += [$iso+" FAIL: "+$n]' \
      --arg n "$note" --arg iso "$(now_iso)"
    read -r cf mx < <(jq -r '[.consecutive_failures, .max_consecutive_failures] | @tsv' "$f")
    echo "FAIL $cf/$mx${note:+ — $note}"
    if [ "$cf" -ge "$mx" ]; then echo "TRIP: max_consecutive_failures reached"; fi
    ;;

  note) # note <file> <text...>
    f="${1:?file}"; shift; txt="$*"
    _write "$f" '.notes += [$iso+" "+$t]' --arg t "$txt" --arg iso "$(now_iso)"
    echo "NOTE: $txt"
    ;;

  phase-set) # phase-set <file> <id> <pending|in_progress|done|blocked> [note]
    f="${1:?file}"; pid="${2:?phase_id}"; pst="${3:?phase_status}"; pnote="${4:-}"
    _write "$f" '
      if (.phases|map(.id)|index($id)) then
        .phases |= map(if .id==$id then (.status=$s | .note=$n) else . end)
      else .phases += [{id:$id,title:$id,status:$s,note:$n}] end' \
      --arg id "$pid" --arg s "$pst" --arg n "$pnote"
    echo "PHASE $pid=$pst${pnote:+ ($pnote)}"
    ;;

  config) # config <file> key=value ...   numeric values stay numeric
    f="${1:?file}"; shift
    [ -f "$f" ] || die "no state file: $f"
    filter="."; args=()
    i=0
    for kv in "$@"; do
      k="${kv%%=*}"; v="${kv#*=}"; i=$((i+1))
      if [[ "$v" =~ ^-?[0-9]+$ ]]; then
        filter+=" | .[\$k${i}]=\$v${i}"; args+=(--arg "k${i}" "$k" --argjson "v${i}" "$v")
      else
        filter+=" | .[\$k${i}]=\$v${i}"; args+=(--arg "k${i}" "$k" --arg "v${i}" "$v")
      fi
    done
    _write "$f" "$filter" "${args[@]}"
    echo "CONFIG updated: $*"
    ;;

  checkpoint-due) # checkpoint-due <file>   exit 0=DUE, 1=not due / none
    f="${1:?file}"
    ev="$(jq -r '.checkpoint_every_seconds' "$f")"
    if [ "$ev" = "0" ] || [ "$ev" = "null" ]; then echo "NONE"; exit 1; fi
    last="$(jq -r '.last_checkpoint_epoch' "$f")"; now="$(now_epoch)"; diff=$((now-last))
    if [ "$diff" -ge "$ev" ]; then echo "DUE: $(jq -r '.checkpoint_action' "$f") (${diff}s/${ev}s)"; exit 0
    else echo "NOT_DUE (${diff}s/${ev}s)"; exit 1; fi
    ;;

  checkpoint-done) # checkpoint-done <file>
    f="${1:?file}"
    _write "$f" '.last_checkpoint_epoch=$now' --argjson now "$(now_epoch)"
    echo "CHECKPOINT recorded"
    ;;

  should-resume) # should-resume <file>  -> DONE | BLOCKED | FRESH | RESUME   (the resumer's decision)
    f="${1:?file}"
    [ -f "$f" ] || { echo "NOFILE"; exit 0; }
    st="$(jq -r '.status' "$f")"
    case "$st" in
      done)    echo "DONE"; ;;
      blocked) echo "BLOCKED: $(jq -r '.blocked_reason // ""' "$f")"; ;;
      working)
        last="$(jq -r '.last_heartbeat_epoch' "$f")"; thr="$(jq -r '.heartbeat_stale_seconds' "$f")"
        now="$(now_epoch)"; diff=$((now-last))
        if [ "$diff" -ge "$thr" ]; then echo "RESUME (stale ${diff}s>=${thr}s) next: $(jq -r '.next_action' "$f")"
        else echo "FRESH (${diff}s<${thr}s)"; fi
        ;;
      *) echo "UNKNOWN_STATUS:$st"; ;;
    esac
    ;;

  register) # register <file>  — add this task to the active registry (dedupe by task_id)
    f="${1:?file}"; [ -f "$f" ] || die "no state file: $f"
    id="$(jq -r '.task_id' "$f")"; abs="$(abspath "$f")"
    touch "$REG"
    awk -F'\t' -v id="$id" '$1!=id' "$REG" > "$REG.tmp" 2>/dev/null && mv "$REG.tmp" "$REG" || true
    printf '%s\t%s\n' "$id" "$abs" >> "$REG"
    echo "REGISTERED $id -> $abs"
    ;;

  unregister) # unregister <file|task_id>
    arg="${1:?file-or-id}"
    if [ -f "$arg" ]; then id="$(jq -r '.task_id' "$arg")"; else id="$arg"; fi
    [ -f "$REG" ] || { echo "no registry"; exit 0; }
    awk -F'\t' -v id="$id" '$1!=id' "$REG" > "$REG.tmp" && mv "$REG.tmp" "$REG"
    echo "UNREGISTERED $id"
    ;;

  list-active) # list-active  — print: <task_id>\t<state_file>\t<status> for every registered task
    [ -f "$REG" ] || exit 0
    while IFS=$'\t' read -r id path; do
      [ -z "${id:-}" ] && continue
      if [ -f "$path" ]; then st="$(jq -r '.status' "$path")"; else st="MISSINGFILE"; fi
      printf '%s\t%s\t%s\n' "$id" "$path" "$st"
    done < "$REG"
    ;;

  status) # status <file>  — human summary
    f="${1:?file}"
    jq -r '"["+.status+(if .blocked_reason then " — "+.blocked_reason else "" end)+"] iter=\(.iteration)/\(.max_iterations) ledger=\(.ledger|length)\nplaybook: \(.playbook_path // "(none)")\nnext: \(.next_action)\nphases:\n" + ((.phases // []) | map("  - \(.id): \(.status)" + (if .note!="" then " ("+.note+")" else "" end)) | join("\n"))' "$f"
    ;;

  dump) f="${1:?file}"; jq . "$f" ;;

  *)
    cat >&2 <<'USAGE'
usage: worklog.sh <cmd> <file> [args]
  init <file> <id> [title]          create state file (no-op if exists)
  heartbeat <file>                  stamp heartbeat, iteration++ (run FIRST each turn)
  set-status <file> <s> [reason]    working | blocked | done
  next <file> <text...>             set next action
  playbook-set <file> <path>        point the state file at its task-specific playbook
  ledger-add <file> <unit>          record completed unit
  ledger-has <file> <unit>          exit 0=HAS / 1=MISSING (idempotency gate)
  fail <file> "<why>"               bump failure counter (prints TRIP at cap)
  note <file> <text...>             append a timestamped note
  phase-set <file> <id> <s> [note]  upsert a phase
  config <file> k=v ...             set knobs (heartbeat_stale_seconds, max_iterations, ...)
  checkpoint-due <file>             exit 0=DUE / 1=not
  checkpoint-done <file>            reset checkpoint timer
  should-resume <file>              DONE | BLOCKED | FRESH | RESUME
  register <file>                   add task to the active registry (for the generic resumer)
  unregister <file|task_id>         remove task from the registry
  list-active                       print <task_id>\t<state_file>\t<status> for all registered tasks
  status <file> | dump <file>       human summary | full JSON
USAGE
    exit 2 ;;
esac
