### Current Goal

* Rewrite the slab allocator (mm/slab.c and include/mm/slab.h). Look for
alternatives to slab allocation, but it looks like it might be the way
to go.

### Progress so far

* 5/19/14: Replaced entry.c with entry.d, such that the kernel drops into D 
           code before running kmain in main/kmain.c

* 5/20/14: After some digging was able to find out how to effectively compile
           D code without the runtime libraries

### Future Goals

* May have to write some parts of the D runtime library myself. 

    * It would be nice to have a GC (so I can work more with objects and 
      dynamic arrays) but this would require the kernel to be preemptable 
      (as the GC must stop the kernel in order to GC). Need to 
      think on/research this more.
