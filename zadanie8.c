int main() {
    unsigned char color_code;
    unsigned short pos;
    char *video_memory = (char*) 0xb8000;

    for (unsigned char bg = 0; bg < 8; bg++) {
        for (unsigned char fg = 0; fg < 16; fg++) {
            color_code = (bg << 4) | fg;
            
            const char *text = "Hello World!";
            pos = (bg * 80) + fg;
            for (int i = 0; text[i] != '\0'; i++) {
                video_memory[2 * (pos + i)] = text[i];
                video_memory[2 * (pos + i) + 1] = color_code;
            }
        }
    }

    while (true);
    return 0;
}
