#!/bin/bash
set -e
set -o pipefail

# Create Setup, Patch, Config scripts
# nixTool-install & and nixTool-uninstall scripts
# Script Templates (i.e. option + variable Template, etc)
# # plan out creation of /opt/nixTool/{etc, var, usr, tmp}
# /opt/nixTool/etc => Config files
# /opt/nixTool/var => logs
# /opt/nixTool/usr => Scripts
# /opt/nixTool/tmp == 'Sandbox' => temporary files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SCRIPT_ROOT="$(cd "$(dirname "${SCRIPT_DIR}")" && pwd)"
SCRIPT_FILE="${SCRIPT_DIR}/$(basename "${BASH_SOURCE[0]}")"
SCRIPT_BASE="$(basename "${SCRIPT_FILE}")"

SCRIPT_TMP_DIR="${SCRIPT_DIR}/tmp"
SCRIPT_ETC_DIR="${SCRIPT_DIR}/etc"
SCRIPT_VAR_DIR="${SCRIPT_DIR}/var"
SCRIPT_USR_DIR="${SCRIPT_DIR}/usr"
SCRIPT_BAK_DIR="${SCRIPT_DIR}/bak"
FILE_STRUC_ERROR_FLAG=0

FILE_STRUC_ARR=("${SCRIPT_TMP_DIR}" "${SCRIPT_ETC_DIR}" "${SCRIPT_VAR_DIR}" "${SCRIPT_USR_DIR}" "${SCRIPT_BAK_DIR}")

prep_NixTool_File_Struc() {
  for k in "${FILE_STRUC_ARR[@]}"; do
    [ ! -f "${k}" ] && mkdir -p "${k}"
  done

  for k in "${FILE_STRUC_ARR[@]}"; do
    if [ ! -d "${k}" ]; then
      mkdir -p "${k}"
    fi
  done
}

repair_FileStruc() {
  printf "\n[INFO] Directories needed for the proper function of nixTool are missing.\n"
  printf "[INFO] Would you like these directories to be created?\n"
  select yn in "Yes" "No"; do
    case $yn in
    Yes)
      prep_NixTool_File_Struc
      break
      ;;
    No) break ;;
    esac
  done
}
check_NixTool_File_Struc() {
  for k in "${FILE_STRUC_ARR[@]}"; do
    if [ -d "${k}" ]; then
      echo "[PASS] Found File: ${k}"
    else
      echo "[FAIL] Missing File: ${k}"
      FILE_STRUC_ERROR_FLAG=1
    fi
  done
}

check_NixTool_File_Struc
[ "${FILE_STRUC_ERROR_FLAG}" -eq 1 ] && repair_FileStruc
