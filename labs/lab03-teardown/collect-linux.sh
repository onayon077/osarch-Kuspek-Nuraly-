#!/usr/bin/env bash
# Run on Ubuntu: bash collect-linux.sh
# This writes actual VM/Linux system output, NOT the Windows host specs.
cd "$(dirname "$0")" || exit 1
mkdir -p evidence
out="evidence/linux-specs.txt"
{
  printf 'Lab 3 - Linux raw command output\n'
  date '+Collected: %Y-%m-%d %H:%M:%S %Z'
  printf '\n$ lscpu\n'; lscpu
  printf '\n$ free -h\n'; free -h
  printf '\n$ sudo dmidecode -t memory\n'; sudo dmidecode -t memory
  printf '\n$ lsblk -d -o NAME,MODEL,ROTA,TRAN,SIZE\n'; lsblk -d -o NAME,MODEL,ROTA,TRAN,SIZE
  printf '\n$ df -h /\n'; df -h /
  printf '\n$ uname -m\n'; uname -m
} > "$out" 2>&1
printf 'Created %s\n' "$(pwd)/$out"
