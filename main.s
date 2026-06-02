.intel_syntax noprefix
.bits 64
.text
.global _start

_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg]
    mov rdx, msglen
    syscall

.data
msg: .string "Hello"
msglen = . - msg