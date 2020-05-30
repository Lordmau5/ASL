state("NFS11")
{
    // 0 = Not Ingame / No Vehicle Control | 1 = Ingame / Vehicle Control
    // This is set to 1 when you bust someone as well...
    // Not set to 1 when you crash though.
    byte ingame : "NFS11.exe", 0xA7AFFC, 0x0, 0x34, 0x30, 0x8, 0x11C;
}

isLoading
{
    return current.ingame != 1;
}