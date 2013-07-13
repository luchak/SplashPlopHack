.SUFFIXES:

BIN_DIR = bin

LIB_CPP_SRCS =

LIB_SRCS = ${LIB_CPP_SRCS}

BIN_SRCS = test_sph.cc

LIB_OBJS = $(LIB_CPP_SRCS:%.cc=%.o)
BIN_OBJS = $(BIN_SRCS:%.cc=%.o)
BINS = $(BIN_SRCS:%.cc=bin/%)

OBJS = ${LIB_OBJS} ${BIN_OBJS}

# Using objects here to represent their source files since both C and C++
# objects have .o extensions.
DEP_SRC_OBJS = ${OBJS}

DEBUG_FLAGS = -g2
DEBUG_OPT_FLAGS = -g -O2 -ffast-math
OPT_FLAGS = -O3 -ffast-math -DNDEBUG

DEPDIR = .deps
depfile = ${DEPDIR}/${*D}/${*F}
MAKEDEPEND = ${CPP} -M -MP -MF ${depfile}.d -MT $*.o ${CPPFLAGS} $<

all: ${BINS}

# We don't want to remake depfiles when we clean.
ifneq (${MAKECMDGOALS},"clean")
-include $(DEP_SRC_OBJS:%.o=${DEPDIR}/%.d)
-include build.mk
endif

CPPFLAGS = -iquote . -I${EIGEN_INCLUDE} -Wall ${DEBUG_FLAGS} ${PLATFORM_CPPFLAGS} -std=c++11
LDFLAGS =  -lpthread ${GL_LIB_FLAGS} ${PLATFORM_LDFLAGS}

build.mk: find_prereqs.sh
	./find_prereqs.sh > build.mk

project_lib.a: ${LIB_OBJS}
	${AR} $@ $^

${BINS}: bin/%: %.o ${LIB_OBJS}
	@mkdir -p bin
	${CPP} -o $@ $^ ${LDFLAGS}

# These two rules get invoked by the include above.
${DEPDIR}/%.d: %.cc
	@mkdir -p ${DEPDIR}/${*D}
	@${MAKEDEPEND}

%.o: %.cc
	${CPP} -o $@ $< -c ${CPPFLAGS}

clean:
	rm -f ${LIB_OBJS} ${BIN_OBJS} ${BINS} project_lib.a build.mk
