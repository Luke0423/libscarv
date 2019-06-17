ifndef REPO_HOME
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

ifndef ARCH
  $(error "undefined environment variable: ARCH"   )
endif
ifndef KERNELS
  $(error "undefined environment variable: KERNELS")
endif

#
# Top-level variables that the included makefiles will modify
#
 
TRASH           =

INSTALL_DIR     =build/$(ARCH)
OBJ_DIR         = $(INSTALL_DIR)/obj
LIB_DIR         = $(INSTALL_DIR)/lib
BIN_DIR         = $(INSTALL_DIR)/bin
HEADER_DIR      = $(INSTALL_DIR)/include/scarv
WORK_DIR        = $(INSTALL_DIR)/work

#CFLAGS         += -Isrc/share

# All object files to be compiled
OBJS            =

# Static libraries to build
LIBS            = 

# Test executables
TESTS           =
TEST_OUTPUTS    =

# Headers to be coppied to the installation dir.
HEADERS         =

# Disassembly targets
DISASM          =
DISASM_DIR      = $(INSTALL_DIR)/disasm

# Object files to be included in libscarv.a
LIBSCARV_LIBID  =libscarv.a
LIBSCARV        =$(LIB_DIR)/$(LIBSCARV_LIBID)
LIBS           +=$(LIBSCARV)

#
# Include the generic top-level configuration makefile.
#
include ${REPO_HOME}/conf/libscarv.conf

#
# Include the architecture specific make file.
#
ifeq ($(ARCH),generic)
    include ${REPO_HOME}/conf/arch.generic
    CFLAGS += -DLIBSCARV_ARCH_GENERIC
else ifeq ($(ARCH),riscv)
    include ${REPO_HOME}/conf/arch.riscv
    CFLAGS += -DLIBSCARV_ARCH_RISCV
else ifeq ($(ARCH),riscv-xcrypto)
    include ${REPO_HOME}/conf/arch.riscv-xcrypto
    CFLAGS += -DLIBSCARV_ARCH_RISCV_XCRYPTO
endif

# Add architecture specific configuration switches to CFLAGS
CFLAGS += $(CONF)

# 1 - header source path
# 2 - destination subfolder
define map_include
$(abspath $(HEADER_DIR)/${2}/$(notdir ${1}))
endef

# 1 - header source path
# 2 - destination subfolder
define tgt_include_header
$(call map_include,${1},${2}) : $(abspath ${1}) ;
	@mkdir -p $(dir $(call map_include,${1},${2}))
	cp $${^} $${@}

endef

# 1 - object file source path
# 2 - destination subfolder
define map_obj
    $(OBJ_DIR)/${2}/$(basename $(notdir ${1})).o
endef

# 1 - object file source path
# 2 - destination subfolder
# 3 - extra flags
define tgt_obj
$(call map_obj,${1},${2}) : ${1} ;
	@mkdir -p $(dir $(call map_obj,${1},${2}))
	$(CC) -c ${CFLAGS} ${3} -o $$@ $$<

endef

# 1 - library name
define map_static_lib
    $(LIB_DIR)/lib$(basename $(notdir ${1})).a
endef

# 1 - Source objects
# 2 - Library name
define tgt_static_lib
$(call map_static_lib,${2}) : ${1} ;
	@mkdir -p $(dir $(call map_static_lib,${2}))
	$(AR) rcs $$@ $$^
endef

# 1 - object file source path
# 2 - destination subfolder
define map_disasm
    $(DISASM_DIR)/${2}/$(basename $(notdir ${1})).dis
endef

# 1 - object file source path
# 2 - destination subfolder
define tgt_disasm
$(call map_disasm,${1},${2}) : $(call map_obj,${1},${2}) ;
	@mkdir -p $(dir $(call map_disasm,${1},${2}))
	$(OBJDUMP) -D $$< > $$@
endef

# 1 - test name
define map_test_bin
$(abspath $(BIN_DIR)/${1}.elf)
endef

# 1 - test name
# 2 - test sources
# 3 - static libraries
# 4 - Include directories
define tgt_test
TESTS  += $(call map_test_bin,${1})
$(call map_test_bin,${1}) : ${2} ${3}
	@mkdir -p $(dir $(call map_test_bin,${1}))
	$(CC) $(CFLAGS) $(addprefix -I,${4}) \
        -I$(INSTALL_DIR)/include \
        -Itest/share \
        -o $${@} $(wildcard test/share/*.c) $${^}
	$(OBJDUMP) -D $${@} > $(DISASM_DIR)/${1}.dis
endef

# 1 - test name
define map_test_output
$(abspath $(WORK_DIR)/${1}.out)
endef

# 1 - test name
define tgt_run_test
TEST_OUTPUTS += $(call map_test_output,${1})
$(call map_test_output,${1}) : $(call map_test_bin,${1})
	mkdir -p $(dir $(call map_test_output,${1}))
	$(TEST_CMD_PREFIX) $(call map_test_bin,${1}) $(TEST_CMD_SUFFIX) > \
	    $(call map_test_output,${1})
	cat $(call map_test_output,${1}) | python3
endef

TEST_CMD_PREFIX =
TEST_CMD_SUFFIX =

ifeq ($(ARCH),generic)
    TEST_CMD_PREFIX =
    TEST_CMD_SUFFIX =
else ifeq ($(ARCH),riscv)
    TEST_CMD_PREFIX =$(RISCV)/bin/spike --isa=rv32imac $(RISCV)/riscv32-unknown-elf/bin/pk
    TEST_CMD_SUFFIX = | tail -n+2
else ifeq ($(ARCH),riscv-xcrypto)
    TEST_CMD_PREFIX =$(RISCV)/bin/spike --isa=rv32imaxc $(RISCV)/riscv32-unknown-elf/bin/pk
    TEST_CMD_SUFFIX = | tail -n+2
endif

#
# GCC tool paths - GCC_PREFIX set by architecture dependent makefile.
#
AS         = ${GCC_PREFIX}as
CC         = ${GCC_PREFIX}gcc
AR         = ${GCC_PREFIX}ar
OBJDUMP    = ${GCC_PREFIX}objdump
OBJCOPY    = ${GCC_PREFIX}objcopy

#
# Include the makefiles responsible for each portion of the library
#

all: headers objects disasm libs tests

# Shared utility code
$(eval $(call tgt_include_header,src/share/util.h,.))
HEADERS += $(call map_include,src/share/util.h,.)

$(foreach KERNEL, ${KERNELS}, $(eval include ./src/${KERNEL}/Makefile.in ./test/${KERNEL}/Makefile.in))

TRASH += $(HEADERS) $(OBJS) $(DISASM) $(LIBS) $(TESTS)

headers: $(HEADERS)
objects: $(OBJS)
libs:    $(LIBS)
disasm:  $(DISASM)
tests:   $(HEADERS) $(LIBS) $(TESTS)

$(LIBSCARV) : $(OBJS)
	@mkdir -p $(dir $@)
	$(AR) rcs $@ $^

test     : $(TEST_OUTPUTS)

venv     : ${REPO_HOME}/requirements.txt
	@${REPO_HOME}/bin/venv.sh

doc      : ${REPO_HOME}/Doxyfile
	@doxygen ${<}

clean    :
	@rm -rf ${REPO_HOME}/build/*
