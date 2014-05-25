module mm.slab;

import include.types;
import include.dbg;

const int SLAB_MAX_ORDER = 5;
const int PAGE_SIZE = 4;

size_t b;

extern(C) void *page_alloc_n(uint32_t n);

private static slab_obj_t *void_to_obj(void *p)
{
  return (cast(slab_obj_t*)p)-1;
}

private static void *obj_to_void(slab_obj_t *s)
{
  return cast(void*)(s+1);
}

private struct slab_obj
{
  private union un
  {
    private slab_obj_t *next; //next free object
    private slab_t *slab; //containing slab
  }
  
  private un u;
  private uint8_t is_free; //true if the object is free

  public void init(slab_obj_t *n)
  {
    this.is_free=1;
    this.u.next=n;
  }

  public slab_obj_t *get_next()
  {
    return this.u.next;
  }

  public slab_t *get_slab()
  {
    return this.u.slab;
  }
  
  public slab_obj_t *alloc(slab_t *s)
  {
    KASSERT(this.is_free==1,"Tried to allocate an allocated obj");
    this.is_free=0;
    this.u.slab=s;
    return &this;
  }

  public void free(slab_obj_t *n)
  {
    KASSERT(this.is_free==0,"Tried to free a free obj");
    is_free=1;
    u.next=n;
  }
}

private struct slab
{
  private slab_t *next; //link on list of slabs
  private slab_obj_t *free_list;  //head of obj free list
  private uint32_t inuse;

  public void init(void *mem,int obj_size,int mem_size, slab_t *n)
  {
    this.next=n;
    this.free_list=null;
    uint64_t total_obj_size=obj_size+slab_obj_t.sizeof;
    int sofar=0;
    slab_obj_t *crrnt=cast(slab_obj_t*)mem;
    while(sofar+total_obj_size <= mem_size)
      {
	(*crrnt).init(this.free_list);
	this.free_list=crrnt;
	crrnt++;
	crrnt=cast(slab_obj_t*)((cast(char*)crrnt)+obj_size);
	sofar+=total_obj_size;
      }
  }
  
  public slab_t *get_next()
  {
    return next;
  }
  
  public slab_obj_t *alloc()
  {
    slab_obj_t *ret=null;
    slab_obj_t *next;
    if(this.free_list)
      {
	next=free_list.get_next();
	ret=free_list.alloc(&this);
	free_list=next;
	this.inuse++;
      }
    return ret;
  }

  public void free(void *p)
  {
    slab_obj_t *obj=void_to_obj(p);
    obj.free(free_list);
    free_list=obj;
    this.inuse--;
  }

  public bool empty()
  {
    return this.inuse==0;
  }
}

struct slab_allocator
{
  private slab_allocator_t *next; //link on list of allocators
  private char *name; 
  private int objsize; //obj size
  private slab_t *slabs; //head of slab list
  private int order; //npages = (1 << order)
  private int slab_nobjs; //number of objs per slab

  public void init(char *name,int size)
  {
    this.next=null;
    this.slabs=null;
    this.name=name;
    int order;
    int min_waste=-1;
    int min_order=0;
    for(order=0;order<=SLAB_MAX_ORDER;order++)
      {
	int crrnt_waste=this.waste(size,order);
	if(crrnt_waste==-1)
	  continue;
	if(min_waste==-1)
	  {
	    min_waste=crrnt_waste;
	    min_order=order;
	  }
	else if(crrnt_waste<min_waste)
	  {
	    min_waste=crrnt_waste;
	    min_order=order;
	  }
	if(crrnt_waste==0)
	  break;
      }
    KASSERT(min_waste!=-1,"Tried to create an allocator named %s beyond the max size",this.name);
    this.order=order;
    this.slab_nobjs=(PAGE_SIZE*(1 << this.order))/size;
  }
  
  public void *slab_obj_alloc()
  {
    slab_obj_t *ret=null;
    slab_t *sb;
    sb=slabs;
    while(!ret && sb)
      {
	ret=sb.alloc();
	sb=sb.get_next();
      }
    if(ret==null)
      this.grow();
    ret=slabs.alloc();
    KASSERT(ret!=null,"New slab failed to alloc in %s",this.name);
    return obj_to_void(ret);
  }

  public void slab_obj_free(void *p)
  {
    slab_obj_t *obj=void_to_obj(p);
    slab_t *slb=obj.get_slab();
    slb.free(p);
  }

  private void grow()
  {
    void *pages=page_alloc_n((1 << this.order));
    slab_t *slb=cast(slab_t*)pages;
    
    (*slb).init(cast(void*)(slb+1),this.objsize,PAGE_SIZE*(1 << this.order),slb);
  }

  private static int waste(int size,int order)
  {
    int mem_size=PAGE_SIZE * (1 << order);
    if(size > mem_size)
      return -1;
    return mem_size - ((mem_size/size)*size);
  }
}

alias slab_obj_t = slab_obj;
alias slab_t = slab;
alias slab_allocator_t = slab_allocator;

extern(C) slab_allocator_t *slab_allocator_create(const char *name,uint size)
{
  return null;
}

extern(C) int slab_allocators_reclaim(int target)
{
  return 0;
}

extern(C) void *slab_obj_alloc(slab_allocator_t *allocator)
{
  return allocator.slab_obj_alloc();
}

extern(C) void slab_obj_free(slab_allocator_t *allocator, void *obj)
{
  return allocator.slab_obj_free(obj);
}

extern(C) void test_allocator_init(const char *name,int size,slab_allocator_t *allocator)
{
  (*allocator).init(cast(char*)name,size);
}

public static slab_allocator_t test_allocator;

extern(C) slab_allocator_t *get_allocator()
{
  return &test_allocator;
}

