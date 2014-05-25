module include.debug

extern(C) void dbg_panic(const char *file, int line, const char *func, const char *fmt, ...);

mixin template panic(fmt,args...)
{
  dbg_panic(__FILE__, __LINE__, __func__, fmt, args);
}


mixin template KASSERT(assrt,fmt,args...)
{
  if(!(assrt))
    mixin panic!(fmt,args);
}
