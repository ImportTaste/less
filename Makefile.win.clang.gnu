# Makefile for less.
# Windows version; clang, gcc compiler

# `make -f Makefile.win.clang.gnu`

#### Start of system configuration section. ####

# !! WIP: get the target correct
# `clang` depends on a host linker (for windows => MSVC `link` or MinGW `gcc`)
# target of clang must correspond to linker libraries used
# LIB (defined by MSVC), and maybe LIBPATH, may interfere with linking
undefine LIB
undefine LIBPATH
# !IFNDEF (TARGET)
TARGET=i686-pc-windows-gnu
# !! possibly set TARGET based upon VCvars_target_cpu if defined
# !ENDIF

# `clang -v -Wno-comment -Wno-deprecated-declarations -Wno-int-to-void-pointer-cast -D_CRT_SECURE_NO_WARNINGS -I. *.c -o main.exe`
# => "C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\BuildTools\\VC\\Tools\\MSVC\\14.15.26726\\bin\\HostX64\\x64\\link.exe" -out:main.exe -defaultlib:libcmt "-libpath:C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\BuildTools\\VC\\Tools\\MSVC\\14.15.26726\\lib\\x64" "-libpath:C:\\Program Files (x86)\\Windows Kits\\10\\Lib\\10.0.17134.0\\ucrt\\x64" "-libpath:C:\\Program Files (x86)\\Windows Kits\\10\\Lib\\10.0.17134.0\\um\\x64" -nologo "C:\\Users\\Roy\\AppData\\Local\\Temp\\brac-ede3eb.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\ch-4a3170.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\charset-c79c8e.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\cmdbuf-e1bd1e.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\command-8d8426.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\cvt-481e61.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\decode-ae4ba8.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\edit-3e15b6.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\filename-6b040b.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\forwback-3a09dc.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\help-9a1e9c.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\ifile-98725d.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\input-818064.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\jump-147d21.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\lessecho-6586ee.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\lesskey-dda4f7.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\line-11159e.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\linenum-59aaec.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\lsystem-f111a1.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\main-6d6a18.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\mark-2bc653.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\optfunc-5642c3.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\option-d74f0f.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\opttbl-9bbd05.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\os-312529.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\output-419c2e.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\pattern-ecadea.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\position-050d69.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\prompt-24bc20.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\regexp-d6e469.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\screen-3ad239.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\search-47a13a.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\signal-fe3556.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\tags-e40d01.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\ttyin-1a52e5.o" "C:\\Users\\Roy\\AppData\\Local\\Temp\\version-c4f2f3.o"

CC = clang
## -v :: verbose output (shows commands to run)
## -O<n> :: <n> == [0 .. 3], increasing level of optimization (see <https://stackoverflow.com/questions/15548023/clang-optimization-levels/15548189#15548189> @@ <https://archive.vn/gzXTw>)
## -pedantic-errors :: error on use of compiler language extensions
## -Werror :: warnings treated as errors
## -Wall :: enable all (usual) warnings
## -Wextra :: enable 'extra' warnings
## -Wno-comment :: suppress warnings about trailing comments on directive lines
## -Wno-deprecated-declarations :: suppress deprecation warnings
CFLAGS = -I. -O3 -pedantic-errors -Werror -Wall -Wno-comment -Wno-deprecated-declarations --target=$(TARGET) -D_CRT_SECURE_NO_WARNINGS
CFLAGS_COMPILE_ONLY = -c
CPPFLAGS =
#LDFLAGS = -g
## see <https://stackoverflow.com/questions/42545078/clang-version-5-and-lnk4217-warning/42752769#42752769>@@<https://archive.is/bK4Di>
## see <http://clang-developers.42468.n3.nabble.com/MinGW-Clang-issues-with-static-libstdc-td4056214.html>
## see <https://clang.llvm.org/docs/LTOVisibility.html>
## -Xclang <arg> :: pass <arg> to clang compiler
## -flto-visibility-public-std :: Use public LTO visibility for classes in std and stdext namespaces
#CXXFLAGS = -Xclang -flto-visibility-public-std ## only needed using `clang` (instead of `clang++`) for CPP files
## -g :: ?
## -static :: link statically (do not link against dynamic libraries)
LDFLAGS = -static

LIBS =

EXEEXT = .exe
O = o

CP = copy

DEFINETYPE = wn
OBJDEP = defines.h less.h

#### End of system configuration section. ####

# Set SHELL to `cmd` for Windows OS (note: ${OS}=="Windows_NT" for XP, 2000, Vista, 7, 10 ...)
# * `make` may otherwise use an incorrect shell (eg, `bash`), if found; "syntax error: unexpected end of file" error output is indicative
ifeq (${OS},Windows_NT)
SHELL := cmd
endif

####

# This rule allows us to supply the necessary -D options
# in addition to whatever the user asks for.
.c.${O}:
	${CC} ${CFLAGS_COMPILE_ONLY} ${CPPFLAGS} ${CFLAGS} $<

OBJ = \
	main.${O} screen.${O} brac.${O} ch.${O} charset.${O} cmdbuf.${O} \
	command.${O} cvt.${O} decode.${O} edit.${O} filename.${O} forwback.${O} \
	help.${O} ifile.${O} input.${O} jump.${O} line.${O} linenum.${O} \
	lsystem.${O} mark.${O} optfunc.${O} option.${O} opttbl.${O} os.${O} \
	output.${O} pattern.${O} position.${O} prompt.${O} search.${O} signal.${O} \
	tags.${O} ttyin.${O} version.${O} regexp.${O}

all: less${EXEEXT} lesskey${EXEEXT}

less${EXEEXT}: ${OBJ}
	${CC} ${CPPFLAGS} ${CFLAGS} ${OBJ} -o $@ ${LDFLAGS} ${LIBS}

lesskey${EXEEXT}: lesskey.${O} version.${O}
	${CC} ${CPPFLAGS} ${CFLAGS} lesskey.${O} version.${O} -o $@ ${LDFLAGS} ${LIBS}

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
