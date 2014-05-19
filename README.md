Current Goal

Rewrite the slab allocator (mm/slab.c and include/mm/slab.h). Look for
alternatives to slab allocation, but it looks like it might be the way
to go.

Progress so far

5/19/14:Replaced entry.c with entry.d, such that the kernel drops into D code before
	running kmain in main/kmain.c