# Hi!
#! https://chatgpt.com/c/69ac74d9-7244-8320-a987-f09bf66ec148

class Elf64_header:
    e_ident = bytearray(16)
    # First 3 bytes -> 7F 45 4C 46 (7F ELF)
    e_type;    # uint16_t
    e_machine; # uint16_t
    e_version; # uint32_t
    e_entry;   # uint64_t
    e_phoff;   # uint64_t
    e_shoff;   # uint64_t
    e_flags;   # uint32_t
    e_ehsize;  # uint16_t
    e_phentsize;  # uint16_t
    e_phnum;  # uint16_t
    e_shentsize;  # uint16_t
    e_shnum;  # uint16_t
    e_shstrndx;  # uint16_t
"""
7F 45 4C 46 02 01 01 00 00 00 00 00 00 00 00 00  # e_ident
02 00                                            # e_type = executable
3E 00                                            # e_machine = x86-64
01 00 00 00                                      # e_version
00 00 00 00 00 00 00 00                          # e_entry (_start placeholder)
40 00 00 00 00 00 00 00                          # e_phoff (offset to program header)
00 00 00 00 00 00 00 00                          # e_shoff (no section headers)
00 00 00 00                                      # e_flags
40 00                                            # e_ehsize = 64
38 00                                            # e_phentsize = 56
01 00                                            # e_phnum = 1
00 00                                            # e_shentsize
00 00                                            # e_shnum
00 00                                            # e_shstrndx
"""
class Program_header:
    p_type; # uint32_t
    p_flags; # uint32_t
    p_offset; # uint64_t
    p_vaddr; # uint64_t
    p_paddr; # uint64_t
    p_filesz; # uint64_t
    p_memsz; # uint64_t
    p_align; # uint64_t


