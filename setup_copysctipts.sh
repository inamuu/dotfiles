#!/bin/bash

set -eu

[ -d "${HOME}/Scripts" ] || mkdir ${HOME}/Scripts

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

cp -rp ${SCRIPT_DIR}/files/scripts/* ${HOME}/Scripts/
