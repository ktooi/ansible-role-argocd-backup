#!/bin/bash

: ${ARGOCD_CONFIG:=/etc/argocd_backup}
[ -r "${ARGOCD_CONFIG}" ] && source "${ARGOCD_CONFIG}"

: ${ARGOCD_CMD:=argocd}
: ${ARGOCD_NS:=argocd}
: ${ARGOCD_BKUP_DIR:=/var/argocd/backup}
: ${ARGOCD_BKUP_FILE:=${ARGOCD_BKUP_DIR}/argocd_backup_$(date '+%Y%m%d-%H%M%S').yaml}
: ${ARGOCD_BKUP_HASH_FILE:=${ARGOCD_BKUP_DIR}/argocd_backup_hash}
: ${ARGOCD_WATCHDOG_FILE:=${ARGOCD_BKUP_DIR}/watchdog}
: ${ARGOCD_LATEST_FILE:=${ARGOCD_BKUP_DIR}/latest}
: ${ARGOCD_KUBECONFIG_FILE:=${HOME}/.kube/config}

function update_watchdog() {
	touch "${ARGOCD_WATCHDOG_FILE}"
}

function export_argocd() {
	"${ARGOCD_CMD}" -n "${ARGOCD_NS}" admin export --kubeconfig "${ARGOCD_KUBECONFIG_FILE}"
}

function calc_hash() {
	__tgt="$1"
	grep -v '^ \+reconciledAt:' "${__tgt}" | md5sum | awk '{print $1}'
}

function main() {
	export_argocd > "${ARGOCD_LATEST_FILE}"
	__latest_hash=$(calc_hash "${ARGOCD_LATEST_FILE}")
	__bkup_hash="0"
	[ -f "${ARGOCD_BKUP_HASH_FILE}" ] && __bkup_hash="$(cat "${ARGOCD_BKUP_HASH_FILE}")"
	if [ "${__bkup_hash}" != "${__latest_hash}" ]; then
		mv "${ARGOCD_LATEST_FILE}" "${ARGOCD_BKUP_FILE}"
		gzip -n "${ARGOCD_BKUP_FILE}"
		echo -n "${__latest_hash}" > "${ARGOCD_BKUP_HASH_FILE}"
	fi
	update_watchdog
}

if [ -z "${ARGOCD_IMPORT}" ]; then
	set -ue
	umask '027'
	main
fi
