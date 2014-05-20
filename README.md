<h3><b>Current Goal</b></h3>

Rewrite the slab allocator (mm/slab.c and include/mm/slab.h). Look for
alternatives to slab allocation, but it looks like it might be the way
to go.

<h3><b>Progress so far</b></h3>

5/19/14:Replaced entry.c with entry.d, such that the kernel drops into D code before
	running kmain in main/kmain.c
