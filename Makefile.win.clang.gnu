# Makefile for less.
# Windows version; clang, gcc compiler

# `make -f Makefile.win.clang.gnu`

# NOTE: does *not* work with multilib MinGW GCC (i686 => missing header errors; x86_64 => link failures)

# spell-checker:ignore (targets) distclean realclean vclean veryclean
# spell-checker:ignore (make) abspath firstword ifeq ifndef ifneq lastword undefine vclean veryclean
#
# spell-checker:ignore (acronyms/names) Borland Borland's LLVM MSVC MinGW POSIX VCvars
# spell-checker:ignore (flags/options) DDEBUG DNDEBUG NDEBUG Werror Wextra Xclang defaultlib dumpmachine flto flto-visibility-public-std libcmt nologo nothrow
# spell-checker:ignore (jargon) multilib
# spell-checker:ignore (shell/win) COMSPEC SystemDrive SystemRoot findstr findstring windir
# spell-checker:ignore (utils) ilink nmake printf
# spell-checker:ignore (vars) BQUOTE CFLAGS CPPFLAGS CXXFLAGS DEFINETYPE DQUOTE EXEEXT LDFLAGS LIBDIR LIBPATH MAKEDIR OBJDEP SHELLSTATUS devnull mkfile
# spell-checker:ignore () brac cmdbuf forwback funcs ifile lessecho lesskey linenum lsystem optfunc opttbl stdext ttyin

#### Start of system configuration section. ####

# `clang` depends on a host linker (for windows => MSVC `link` or MinGW `gcc`)
# target of clang must correspond to linker libraries used
# LIB (defined by MSVC), and maybe LIBPATH, may interfere with linking
undefine LIB
undefine LIBPATH

CC = clang
CC_ABI = gnu
## -g :: produce debugging information
## -v :: verbose output (shows commands to run)
## -O<n> :: <n> == [0 .. 3], increasing level of optimization (see <https://stackoverflow.com/questions/15548023/clang-optimization-levels/15548189#15548189> @@ <https://archive.vn/gzXTw>)
## -pedantic-errors :: error on use of compiler language extensions
## -Werror :: warnings treated as errors
## -Wall :: enable all (usual) warnings
## -Wextra :: enable 'extra' warnings
## -Wno-comment :: suppress warnings about trailing comments on directive lines
## -Wno-deprecated-declarations :: suppress warnings about deprecated POSIX function names
CFLAGS = -I. -pedantic-errors -Werror -Wall -Wno-comment -Wno-deprecated-declarations
CFLAGS_COMPILE_ONLY = -c
CPPFLAGS =
## see <https://stackoverflow.com/questions/42545078/clang-version-5-and-lnk4217-warning/42752769#42752769>@@<https://archive.is/bK4Di>
## see <http://clang-developers.42468.n3.nabble.com/MinGW-Clang-issues-with-static-libstdc-td4056214.html>
## see <https://clang.llvm.org/docs/LTOVisibility.html>
## -Xclang <arg> :: pass <arg> to clang compiler
## -flto-visibility-public-std :: Use public LTO visibility for classes in std and stdext namespaces
# CXXFLAGS = -Xclang -flto-visibility-public-std ## only needed using `clang` (instead of `clang++`) for CPP files
## -static :: link statically (do not link against dynamic libraries)
LDFLAGS = -static

LIBS =

EXEEXT = .exe
O = o

CP = copy

DEFINETYPE = wn
OBJDEP = defines.h less.h funcs.h cmd.h

DEBUG ?= 0
ifeq ($(DEBUG),0)
	CFLAGS += -DNDEBUG -O3
else
	CFLAGS += -DDEBUG -O0 -g
endif

#### End of system configuration section. ####

# require at least `make` v4.0+ (minimum needed for correct path functions)
MAKE_VERSION_major := $(word 1,$(subst ., ,$(MAKE_VERSION)))
MAKE_VERSION_minor := $(word 2,$(subst ., ,$(MAKE_VERSION)))
MAKE_VERSION_fail := $(filter $(MAKE_VERSION_major),3 2 1 0)
ifeq (${MAKE_VERSION_major},4)
MAKE_VERSION_fail := $(filter $(MAKE_VERSION_minor),)
endif
ifneq ($(MAKE_VERSION_fail),)
$(info MAKE_VERSION=${MAKE_VERSION})
# $(info MAKE_VERSION_major=${MAKE_VERSION_major})
# $(info MAKE_VERSION_minor=${MAKE_VERSION_minor})
$(error ERR!: `make` v4.0+ required)
endif

# Set SHELL to `cmd` for Windows OS (note: environment/${OS}=="Windows_NT" for XP, 2000, Vista, 7, 10 ...)
# * `make` may otherwise use an incorrect shell (eg, `bash`), if found; "syntax error: unexpected end of file" error output is indicative
ifeq (${OS},Windows_NT)
	# use case and location fallbacks; note: assumes *no spaces* within ${ComSpec}, ${SystemRoot}, or ${windir}
	COMSPEC := $(or ${ComSpec},${COMSPEC},${comspec})
	SystemRoot := $(or ${SystemRoot},${SYSTEMROOT},${systemroot},${windir})
	SHELL := $(firstword $(wildcard ${COMSPEC} ${SystemRoot}/System32/cmd.exe) cmd)
endif
# $(info SHELL=${SHELL})

devnull := /dev/null
NULL :=
SPACE := $() $()
DQUOTE := \"
BQUOTE := $(firstword \` \`)
ifeq ($(OS),Windows_NT)
devnull := NUL
DQUOTE := $(subst \,,$(DQUOTE))
BQUOTE := $(subst \,,$(BQUOTE))
endif

mkfile_path := $(lastword ${MAKEFILE_LIST})
mkfile_abs_path := $(abspath ${mkfile_path})
mkfile_dir := $(abspath $(dir ${mkfile_abs_path}))
ifeq (${OS},Windows_NT)
current_dir := $(abspath $(shell cmd /x/d/c echo %CD%))
else
current_dir := $(abspath $(shell echo $$PWD))
endif

# $(info mkfile_path="$(mkfile_path)")
# $(info mkfile_abs_path="$(mkfile_abs_path)")
# $(info mkfile_dir="$(mkfile_dir)")
# $(info current_dir="$(current_dir)")

ifeq (${SPACE},$(findstring ${SPACE},${mkfile_abs_path}))
$(error WARN: <space>'s within project directory may cause issues)
endif

ifneq (${TARGET},)
CFLAGS += --target=${TARGET}
else
ifneq (${ARCH},$(filter ${ARCH},32 i686 x32 x86 64 x64 x86_64))
$(error ERR!: Unknown architecture "$(ARCH)"; valid values are ["", "32", "i686", "x32", "x86", "64", "x64", "x86_64"])
endif
ifeq (${OS},Windows_NT)
ifeq (${ARCH},)
CC_machine := $(shell ${CC} -dumpmachine)
override ARCH := $(or $(filter $(subst -, ,${CC_machine}),i686 x86_64),i686)
endif
# $(info ARCH="${ARCH}")
endif
ifneq (,$(filter ${ARCH},32 i686 x32 x86))
ARCH_norm := 32
TARGET := i686-unknown-windows-${CC_ABI}
endif
ifneq (,$(filter ${ARCH},64 x64 x86_64))
ARCH_norm := 64
TARGET := x86_64-unknown-windows-${CC_ABI}
endif
CFLAGS += -m${ARCH_norm} --target=${TARGET}
# LDFLAGS += -m${ARCH_norm}
endif # defined ${TARGET}

# $(info CC=$(CC))
# $(info CFLAGS=$(CFLAGS))
# $(info ARCH=$(ARCH))
# $(info ARCH_norm=$(ARCH_norm))
# $(info TARGET=$(TARGET))

####

# This rule allows us to supply the necessary -D options
# in addition to whatever the user asks for.
.c.${O}:
	${CC} ${CFLAGS_COMPILE_ONLY} ${CPPFLAGS} ${CFLAGS} "$<"

OBJ = \
	main.${O} screen.${O} brac.${O} ch.${O} charset.${O} cmdbuf.${O} \
	command.${O} cvt.${O} decode.${O} edit.${O} filename.${O} forwback.${O} \
	help.${O} ifile.${O} input.${O} jump.${O} line.${O} linenum.${O} \
	lsystem.${O} mark.${O} optfunc.${O} option.${O} opttbl.${O} os.${O} \
	output.${O} pattern.${O} position.${O} prompt.${O} search.${O} signal.${O} \
	tags.${O} ttyin.${O} version.${O} regexp.${O}

all: less${EXEEXT} lesskey${EXEEXT}

less${EXEEXT}: ${OBJ}
	${CC} ${CPPFLAGS} ${CFLAGS} ${OBJ} -o "$@" ${LDFLAGS} ${LIBS}

lesskey${EXEEXT}: lesskey.${O} version.${O}
	${CC} ${CPPFLAGS} ${CFLAGS} lesskey.${O} version.${O} -o "$@" ${LDFLAGS} ${LIBS}

${OBJ}: ${OBJDEP}

defines.h: defines.${DEFINETYPE}
	${CP} defines.${DEFINETYPE} defines.h

clean:
	-if EXIST "*.${O}" del *.${O}
	-if EXIST "defines.h" del defines.h
	-if EXIST "less${EXEEXT}" del less${EXEEXT}
	-if EXIST "lesskey${EXEEXT}" del lesskey${EXEEXT}

build: all
compile: ${OBJ}
realclean: clean
rebuild: clean build
veryclean: realclean
