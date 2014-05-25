#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "include/slab.h"

typedef unsigned int uint32_t;
struct slab_allocator;

void test_allocator_init(const char *name,int size, slab_allocator_t *allocator);
void *page_alloc_n(uint32_t n);
slab_allocator_t *get_allocator();
void dbg_panic(const char *file,int line,const char*func,const char *fmt,...);

int main()
{
  slab_allocator_t *test_allocator=get_allocator();
  test_allocator_init("test",4,test_allocator);
}


void *page_alloc_n(uint32_t n)
{
  return malloc(4*n);
}

void dbg_panic(const char *file,int line,const char*func,const char *fmt,...)
{
  char buf[4096];
  va_list args;
  va_start(args, fmt);
  
  printf("panic in %s:%u %s(): ", file, line, func);
  vsnprintf(buf, 4096, fmt, args);
  printf("%s", buf);
  printf("\nKernel Halting.\n\n");
	
  va_end(args);
  
  exit(1);
}
