#include <ctype.h>
#include <dirent.h>
#include <fcntl.h>
#include <linux/input.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define KEY_ESC 1
#define TERM_GRACE_MS 2000
#define POLL_MS 100

// Signals every process (except ourselves) whose command line contains
// `name`, like `pkill -f`. Returns how many processes matched.
static int signal_matching(const char *name, int sig)
{
    DIR *proc = opendir("/proc");
    if (!proc)
        return 0;

    pid_t self = getpid();
    int count = 0;
    struct dirent *entry;

    while ((entry = readdir(proc)) != NULL) {
        if (!isdigit((unsigned char)entry->d_name[0]))
            continue;
        pid_t pid = (pid_t)atoi(entry->d_name);
        if (pid == self)
            continue;

        char path[64], cmdline[1024];
        snprintf(path, sizeof(path), "/proc/%d/cmdline", pid);
        FILE *fp = fopen(path, "r");
        if (!fp)
            continue;
        size_t len = fread(cmdline, 1, sizeof(cmdline) - 1, fp);
        fclose(fp);
        if (len == 0)
            continue;

        // cmdline args are NUL separated, join them like pkill -f does
        for (size_t i = 0; i < len; i++)
            if (cmdline[i] == '\0')
                cmdline[i] = ' ';
        cmdline[len] = '\0';

        if (strstr(cmdline, name) && kill(pid, sig) == 0)
            count++;
    }

    closedir(proc);
    return count;
}

int main(int argc, char *argv[])
{
    if (argc < 2) {
        printf("Usage: %s program_name\n", argv[0]);
        return 1;
    }

    int input_fd = open("/dev/input/event0", O_RDONLY);
    struct input_event event;

    while (read(input_fd, &event, sizeof(event)) == sizeof(event)) {
        if (event.type == EV_KEY && event.value == 1 && event.code == KEY_ESC) {
            // Ask nicely first so apps can restore the display and save (#1222),
            // then SIGKILL whatever is still alive after the grace period.
            if (signal_matching(argv[1], SIGTERM) > 0) {
                for (int waited = 0; waited < TERM_GRACE_MS; waited += POLL_MS) {
                    usleep(POLL_MS * 1000);
                    if (signal_matching(argv[1], 0) == 0)
                        break;
                }
                signal_matching(argv[1], SIGKILL);
            }
            break;
        }
    }

    close(input_fd);
    return 0;
}
