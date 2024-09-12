#!/usr/bin/env bash
set +x
set -euo pipefail
echo "deb http://dl.astralinux.ru/astra/frozen/1.7_x86-64/1.7.6/repository-main/ 1.7_x86-64 main contrib non-free" >> /etc/apt/sources.list
echo "deb http://dl.astralinux.ru/astra/frozen/1.7_x86-64/1.7.6/repository-update/ 1.7_x86-64 main contrib non-free" >> /etc/apt/sources.list
apt update
astra-update -A -r
# use curl
# bash <(curl -ksL https://raw.githubusercontent.com/andy0mg/DebianLikeBitrixVM/master/update_astra.sh)
