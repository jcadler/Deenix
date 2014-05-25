module include.dbg;

extern (C) void dbg_panic(const char *file, int line, const char *func, const char *fmt, ...);

template panic(string file=__FILE__,size_t line=__LINE__,string func=__FUNCTION__,Args...)
{
  void panic(char *fmt,Args args)
  {
    dbg_panic(cast(const(char*))file,cast(int)line,cast(const(char*))func,fmt,args);
  }
}
template KASSERT(string file=__FILE__,size_t line=__LINE__,string func=__FUNCTION__,Args...)
{
  void KASSERT(bool assrt,const char *fmt,Args args)
  {
    if(!(assrt))
      dbg_panic(cast(const(char*))file,cast(int)line,cast(const(char*))func,fmt,args);
  }
}
