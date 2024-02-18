#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

case `uname -m` in
  x86_64)
    echo "TARGET_ARCH_X86_64"
    ;;
  aarch64)
    echo "TARGET_ARCH_ARM64"
    ;;
  ppc64le)
    echo "TARGET_ARCH_PPC64LE"
    ;;
esac
