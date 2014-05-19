void halt()
{
  __asm__("cli\n\t"
                "hlt");
}
