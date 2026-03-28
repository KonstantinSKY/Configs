#!/usr/bin/env bash

set -euo pipefail

VM_NAME="${VM_NAME:-manjaro-rehearsal}"
LIBVIRT_URI="${LIBVIRT_URI:-qemu:///system}"
KVM_ROOT="${KVM_ROOT:-$HOME/Work/KVMs}"
CONFIG_ROOT="${CONFIG_ROOT:-$HOME/Work/Configs/kvm}"
XML_DIR="${XML_DIR:-$CONFIG_ROOT/xmls}"
NETWORK_NAME="${NETWORK_NAME:-default}"
OS_VARIANT="${OS_VARIANT:-manjaro}"
MEMORY_MB="${MEMORY_MB:-8192}"
VCPUS="${VCPUS:-2}"
DISK_GB="${DISK_GB:-30}"
CPU_MODE="${CPU_MODE:-host-passthrough}"
GRAPHICS="${GRAPHICS:-spice}"
VIDEO_MODEL="${VIDEO_MODEL:-virtio}"
DRY_RUN="${DRY_RUN:-0}"
SAVE_XML="${SAVE_XML:-1}"

ISO_PATH="${ISO_PATH:-}"
STAGED_ISO_PATH="${STAGED_ISO_PATH:-$KVM_ROOT/isos/$(basename "${ISO_PATH:-manjaro.iso}")}"
RUNTIME_ISO_PATH=""
DISK_PATH="${DISK_PATH:-$KVM_ROOT/disks/${VM_NAME}.qcow2}"
XML_PATH="${XML_PATH:-$XML_DIR/${VM_NAME}.xml}"

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

resolve_iso() {
    if [[ -n "$ISO_PATH" ]]; then
        return
    fi

    local latest
    latest="$(
        {
            find "$HOME/Downloads" -maxdepth 1 -type f -name 'manjaro-*.iso' -printf '%T@ %p\n' 2>/dev/null
            find "$KVM_ROOT/isos" -maxdepth 1 -type f -name 'manjaro-*.iso' -printf '%T@ %p\n' 2>/dev/null
        } | sort -nr | awk 'NR==1 {print $2}'
    )"
    [[ -n "$latest" ]] || fail "No Manjaro ISO found in $HOME/Downloads or $KVM_ROOT/isos"
    ISO_PATH="$latest"
}

stage_iso_if_needed() {
    local src_size dst_size

    RUNTIME_ISO_PATH="$ISO_PATH"
    STAGED_ISO_PATH="${STAGED_ISO_PATH:-$KVM_ROOT/isos/$(basename "$ISO_PATH")}"

    if [[ "$ISO_PATH" == "$STAGED_ISO_PATH" ]]; then
        return
    fi

    mkdir -p "$(dirname "$STAGED_ISO_PATH")"

    if [[ -f "$STAGED_ISO_PATH" ]]; then
        src_size="$(stat -c '%s' "$ISO_PATH")"
        dst_size="$(stat -c '%s' "$STAGED_ISO_PATH")"
        if [[ "$src_size" == "$dst_size" ]]; then
            RUNTIME_ISO_PATH="$STAGED_ISO_PATH"
            return
        fi
    fi

    if cp -f "$ISO_PATH" "$STAGED_ISO_PATH" 2>/dev/null || mv -f "$ISO_PATH" "$STAGED_ISO_PATH" 2>/dev/null; then
        chmod 0644 "$STAGED_ISO_PATH" || true
        RUNTIME_ISO_PATH="$STAGED_ISO_PATH"
        return
    fi

    # If the caller cannot read the ISO directly, let libvirt use the original
    # path after host ACLs are adjusted for qemu.
    RUNTIME_ISO_PATH="$ISO_PATH"
}

need_cmd virsh
need_cmd virt-install
need_cmd qemu-img

resolve_iso

[[ -f "$ISO_PATH" ]] || fail "ISO not found: $ISO_PATH"
mkdir -p "$KVM_ROOT/disks" "$KVM_ROOT/nvram" "$KVM_ROOT/isos" "$XML_DIR"

if [[ "$DRY_RUN" == "0" ]]; then
    STAGED_ISO_PATH="$KVM_ROOT/isos/$(basename "$ISO_PATH")"
    stage_iso_if_needed
else
    RUNTIME_ISO_PATH="$ISO_PATH"
fi

if virsh --connect "$LIBVIRT_URI" dominfo "$VM_NAME" >/dev/null 2>&1; then
    fail "Domain already exists: $VM_NAME"
fi

virsh --connect "$LIBVIRT_URI" net-info "$NETWORK_NAME" >/dev/null 2>&1 || fail "Libvirt network not found: $NETWORK_NAME"

if [[ -e "$DISK_PATH" ]]; then
    fail "Disk image already exists: $DISK_PATH"
fi

qemu-img create -f qcow2 "$DISK_PATH" "${DISK_GB}G" >/dev/null

cleanup_disk() {
    if [[ -f "$DISK_PATH" ]]; then
        rm -f "$DISK_PATH"
    fi
}

if [[ "$DRY_RUN" == "1" ]]; then
    trap cleanup_disk EXIT
fi

cleanup_failed_create() {
    local rc=$?

    if [[ "$DRY_RUN" != "0" || "$rc" -eq 0 ]]; then
        return
    fi

    virsh --connect "$LIBVIRT_URI" destroy "$VM_NAME" >/dev/null 2>&1 || true
    virsh --connect "$LIBVIRT_URI" undefine "$VM_NAME" --nvram >/dev/null 2>&1 || \
        virsh --connect "$LIBVIRT_URI" undefine "$VM_NAME" >/dev/null 2>&1 || true
    rm -f "$DISK_PATH" "$XML_PATH"
    exit "$rc"
}

trap cleanup_failed_create ERR

virt_install_cmd=(
    virt-install
    --connect "$LIBVIRT_URI"
    --name "$VM_NAME"
    --memory "$MEMORY_MB"
    --vcpus "$VCPUS"
    --cpu "$CPU_MODE"
    --machine q35
    --osinfo "$OS_VARIANT"
    --cdrom "$RUNTIME_ISO_PATH"
    --disk "path=$DISK_PATH,format=qcow2,bus=virtio,discard=unmap"
    --network "network=$NETWORK_NAME,model=virtio"
    --graphics "$GRAPHICS"
    --video "$VIDEO_MODEL"
    --sound none
    --controller "type=usb,model=qemu-xhci"
    --input "tablet,bus=usb"
    --channel spicevmc
    --rng /dev/urandom
    --boot "uefi,menu=on"
    --noautoconsole
)

if [[ "$DRY_RUN" == "1" ]]; then
    virt_install_cmd+=(--dry-run --print-xml)
fi

printf 'VM_NAME=%s\n' "$VM_NAME"
printf 'ISO_PATH=%s\n' "$ISO_PATH"
printf 'RUNTIME_ISO_PATH=%s\n' "$RUNTIME_ISO_PATH"
printf 'DISK_PATH=%s\n' "$DISK_PATH"
printf 'MEMORY_MB=%s\n' "$MEMORY_MB"
printf 'VCPUS=%s\n' "$VCPUS"
printf 'DISK_GB=%s\n' "$DISK_GB"
printf 'NETWORK_NAME=%s\n' "$NETWORK_NAME"
printf 'DRY_RUN=%s\n' "$DRY_RUN"

"${virt_install_cmd[@]}"

if [[ "$DRY_RUN" == "0" && "$SAVE_XML" == "1" ]]; then
    virsh --connect "$LIBVIRT_URI" dumpxml --inactive "$VM_NAME" > "$XML_PATH"
    printf 'Saved domain XML to %s\n' "$XML_PATH"
fi
