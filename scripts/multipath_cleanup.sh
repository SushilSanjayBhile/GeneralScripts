#!/bin/bash
# multipath_cleanup.sh v2
# Handles: map-in-use flush, zombie maps, multiple maps, iterative re-scan

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log()   { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
step()  { echo -e "${CYAN}[STEP]${NC}  $*"; }

[[ $EUID -ne 0 ]] && { error "Must run as root."; exit 1; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true && warn "DRY RUN mode — no changes will be made."

run() {
  if $DRY_RUN; then echo "  [dry-run] $*"
  else eval "$@"; fi
}

flush_map() {
  local MAP="$1"
  log "  Attempting multipath -f $MAP ..."
  if multipath -f "$MAP" 2>&1 | grep -q "map in use"; then
    warn "  '$MAP' is in use. Trying dmsetup remove..."
    if dmsetup info "$MAP" &>/dev/null; then
      run "dmsetup remove --force $MAP" \
        && log "  $MAP removed via dmsetup." \
        || warn "  dmsetup also failed for $MAP — will retry after path removal."
    fi
  else
    log "  $MAP flushed via multipath."
  fi
}

remove_slave_devs() {
  local -a DEVS=("$@")
  for DEV in "${DEVS[@]}"; do
    local SYSFS="/sys/block/${DEV}/device/delete"
    if [[ -f "$SYSFS" ]]; then
      log "  Removing /dev/$DEV via sysfs..."
      run "echo 1 > $SYSFS" && log "  /dev/$DEV removed." || warn "  Failed: /dev/$DEV"
    else
      warn "  /sys/block/$DEV/device/delete not found — already gone."
    fi
  done
}

cleanup_round() {
  local ROUND="$1"
  echo ""
  echo "======================================"
  echo " Cleanup Round $ROUND"
  echo "======================================"

  # Parse multipath -ll output
  local MP_OUTPUT
  MP_OUTPUT=$(multipath -ll 2>/dev/null) || true

  # Collect maps
  local -a MAPS=()
  while IFS= read -r line; do
    if [[ "$line" =~ ^(mpath[a-z]+)[[:space:]]+\(([0-9a-f]+)\) ]]; then
      MAPS+=("${BASH_REMATCH[1]}")
    fi
  done <<< "$MP_OUTPUT"

  if [[ ${#MAPS[@]} -eq 0 ]]; then
    log "No multipath maps found. Nothing to do."
    return 1  # signal: done
  fi

  # Collect faulty slave devices
  local -a SLAVES=()
  while IFS= read -r line; do
    if [[ "$line" =~ [[:space:]](sd[a-z]+)[[:space:]]+[0-9]+:[0-9]+[[:space:]]+failed[[:space:]]+faulty ]]; then
      SLAVES+=("${BASH_REMATCH[1]}")
    fi
  done <<< "$MP_OUTPUT"

  echo ""
  log "Maps found     : ${MAPS[*]}"
  log "Faulty slaves  : ${SLAVES[*]:-none}"
  echo ""

  # Step A: Try to flush each map first (before path removal)
  step "Flushing multipath maps..."
  for MAP in "${MAPS[@]}"; do
    $DRY_RUN || flush_map "$MAP"
  done

  # Step B: Remove all faulty slave devices
  if [[ ${#SLAVES[@]} -gt 0 ]]; then
    step "Removing faulty SCSI block devices from sysfs..."
    remove_slave_devs "${SLAVES[@]}"
  else
    log "No faulty slaves to remove."
  fi

  # Step C: After path removal, retry flush for any zombie maps
  step "Retrying flush on remaining maps..."
  for MAP in "${MAPS[@]}"; do
    if dmsetup info "$MAP" &>/dev/null 2>&1; then
      log "  $MAP still present, retrying multipath -f..."
      run "multipath -f $MAP 2>/dev/null" || {
        warn "  Still in use. Forcing via dmsetup..."
        run "dmsetup remove --force $MAP" || warn "  Could not remove $MAP"
      }
    else
      log "  $MAP already gone."
    fi
  done

  # Step D: Reconfigure
  step "Running multipath -r to reconfigure..."
  run "multipath -r 2>/dev/null" || true

  return 0  # signal: continue
}

# ── Main ──────────────────────────────────────────────────────────────────────
echo "======================================"
echo " Multipath Device Cleanup Script v2"
echo "======================================"

read -rp "Proceed with cleanup? [y/N] " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { warn "Aborted."; exit 0; }

MAX_ROUNDS=5
for ((ROUND=1; ROUND<=MAX_ROUNDS; ROUND++)); do
  cleanup_round "$ROUND" || break

  # Check if anything remains
  REMAINING=$(multipath -ll 2>/dev/null | grep -c "^mpath" || true)
  if [[ "$REMAINING" -eq 0 ]]; then
    log "All multipath maps cleaned up after round $ROUND."
    break
  else
    warn "$REMAINING map(s) still present. Running round $((ROUND+1))..."
    sleep 1
  fi
done

echo ""
echo "======================================"
echo " Final multipath status:"
echo "======================================"
multipath -ll 2>/dev/null || echo "(no maps remaining)"

# Check for any lingering dm devices
echo ""
step "Checking for orphaned dm devices..."
dmsetup ls 2>/dev/null | grep mpath || echo "(no orphaned mpath dm devices)"
