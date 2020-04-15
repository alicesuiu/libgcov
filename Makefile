# Build libgcov components.
objext = .o
CC = gcc
CFLAGS = -g -O2

LIBGCC2_INCLUDES =
HOST_LIBGCC2_CFLAGS =
LIBGCC2_DEBUG_CFLAGS = -g
LIBGCC2_CFLAGS = -O2 $(LIBGCC2_INCLUDES) $(HOST_LIBGCC2_CFLAGS) \
		 $(LIBGCC2_DEBUG_CFLAGS) -DIN_LIBGCC2 -fbuilding-libgcc -fno-stack-protector

INTERNAL_CFLAGS = $(CFLAGS) $(LIBGCC2_CFLAGS) $(HOST_LIBGCC2_CFLAGS) -DHAVE_CC_TLS

gcc_compile_bare = $(CC) $(INTERNAL_CFLAGS)
compile_deps = -MT $@ -MD -MP -MF $(basename $@).dep
gcc_compile = $(gcc_compile_bare) -o $@ $(compile_deps)

LIBGCOV_MERGE = _gcov_merge_add _gcov_merge_single			\
	_gcov_merge_ior _gcov_merge_time_profile _gcov_merge_icall_topn
LIBGCOV_PROFILER = _gcov_interval_profiler				\
	_gcov_interval_profiler_atomic					\
	_gcov_pow2_profiler						\
	_gcov_pow2_profiler_atomic					\
	_gcov_one_value_profiler					\
	_gcov_one_value_profiler_atomic					\
	_gcov_average_profiler						\
	_gcov_average_profiler_atomic					\
	_gcov_ior_profiler						\
	_gcov_ior_profiler_atomic					\
	_gcov_indirect_call_profiler_v2					\
	_gcov_time_profiler						\
	_gcov_indirect_call_topn_profiler
LIBGCOV_INTERFACE = _gcov_dump _gcov_flush _gcov_fork			\
	_gcov_execl _gcov_execlp					\
	_gcov_execle _gcov_execv _gcov_execvp _gcov_execve _gcov_reset
LIBGCOV_DRIVER = _gcov

libgcov-merge-objects = $(patsubst %,%$(objext),$(LIBGCOV_MERGE))
libgcov-profiler-objects = $(patsubst %,%$(objext),$(LIBGCOV_PROFILER))
libgcov-interface-objects = $(patsubst %,%$(objext),$(LIBGCOV_INTERFACE))
libgcov-driver-objects = $(patsubst %,%$(objext),$(LIBGCOV_DRIVER))
libgcov-objects = $(libgcov-merge-objects) $(libgcov-profiler-objects) \
                 $(libgcov-interface-objects) $(libgcov-driver-objects)

$(libgcov-merge-objects): %$(objext): libgcov-merge.c gcov.h libgcov.h
	$(gcc_compile) -DL$* -c libgcov-merge.c
$(libgcov-profiler-objects): %$(objext): libgcov-profiler.c gcov.h libgcov.h
	$(gcc_compile) -DL$* -c libgcov-profiler.c
$(libgcov-interface-objects): %$(objext): libgcov-interface.c gcov.h libgcov.h
	$(gcc_compile) -DL$* -c libgcov-interface.c
$(libgcov-driver-objects): %$(objext): libgcov-driver.c libgcov-driver-system.c gcov.h libgcov.h
	$(gcc_compile) -DL$* -c libgcov-driver.c

libgcov.a: $(libgcov-objects)
	ar rcs $@ $^

all: libgcov.a

clean:
	rm -rf *.o *.dep libgcov.a