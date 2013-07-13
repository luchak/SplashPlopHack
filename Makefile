.SUFFIXES:

BIN_DIR = bin

LIB_CPP_SRCS = kernels.cc \
							 particle.cc

LIB_SRCS = ${LIB_CPP_SRCS}

BIN_SRCS = test_sph.cc

LIB_OBJS = $(LIB_CPP_SRCS:%.cc=objs/%.o)
BIN_OBJS = $(BIN_SRCS:%.cc=objs/%.o)
BINS = $(BIN_SRCS:%.cc=bin/%)

OBJS = ${LIB_OBJS} ${BIN_OBJS}

# Using objects here to represent their source files since both C and C++
# objects have .o extensions.
DEP_SRC_OBJS = ${OBJS}

DEBUG_FLAGS = -g
DEBUG_OPT_FLAGS = -g -O2 -ffast-math
OPT_FLAGS = -O3 -ffast-math -DNDEBUG

DEPDIR = .deps
depfile = ${DEPDIR}/${*D}/${*F}
MAKEDEPEND = ${CPP} -M -MP -MF ${depfile}.d -MT $*.o ${CPPFLAGS} $<

all: ${BINS}

# We don't want to remake depfiles when we clean.
ifneq (${MAKECMDGOALS},"clean")
-include $(DEP_SRC_OBJS:objs/%.o=${DEPDIR}/%.d)
-include build.mk
endif

CPPFLAGS = -iquote . -Wall ${OPT_FLAGS} ${PLATFORM_CPPFLAGS} -std=c++11
LDFLAGS =  -lpthread ${GL_LIB_FLAGS} ${PLATFORM_LDFLAGS} -lprofiler

build.mk: find_prereqs.sh
	./find_prereqs.sh > build.mk

${BINS}: bin/%: objs/%.o ${LIB_OBJS}
	@mkdir -p bin
	${CPP} -o $@ $^ ${LDFLAGS}

# These two rules get invoked by the include above.
${DEPDIR}/%.d: %.cc
	@mkdir -p ${DEPDIR}/${*D}
	@${MAKEDEPEND}

objs/%.o: %.cc
	@mkdir -p objs
	${CPP} -o $@ $< -c ${CPPFLAGS}

clean:
	rm -f ${LIB_OBJS} ${BIN_OBJS} ${BINS} build.mk
