void main() {

    char* video_memory = 0xb8000;
    char* message = "Hello from 64-bit Bare Metal!";
    
    int i = 0;
    while (message[i] != 0) {
        // Character byte
        video_memory[i * 2] = message[i];
        // Attribute byte (White text on black background)
        video_memory[i * 2 + 1] = 0x0f;
        i++;
    }

    // Halt the CPU
    while(1) { __asm__("hlt"); }
}