# Copyright (C) 2019 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which 
# can be found at https://opensource.org/licenses/MIT (or should be included 
# as LICENSE.txt within the associated archive or repository).

include ${REPO_HOME}/conf/share.mk

# =============================================================================

ifndef RISCV_XCRYPTO
  $(error "point RISCV_XCRYPTO environment variable at toolchain installation")
endif

# -----------------------------------------------------------------------------

export ARCH_SUBSET        = rv32imaxc
export ARCH_ABI           = ilp32

export TOOL_PREFIX_TARGET = riscv32-
export TOOL_PREFIX_VENDOR = unknown-
export TOOL_PREFIX_ABI    = elf-

export TOOL_PREFIX        = ${RISCV_XCRYPTO}/bin/${TOOL_PREFIX_TARGET}${TOOL_PREFIX_VENDOR}${TOOL_PREFIX_ABI}

export TEST_PREFIX        = ${RISCV_XCRYPTO}/bin/spike --isa=${ARCH_SUBSET} ${RISCV_XCRYPTO}/riscv32-unknown-elf/bin/pk
export TEST_SUFFIX        = | tail -n+2

export CC_PATHS           =
export CC_FLAGS           = -Wall -O3 -march=${ARCH_SUBSET} -mabi=${ARCH_ABI} 
export CC_LIBS            =

# =============================================================================
