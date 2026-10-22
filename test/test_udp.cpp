#include <arpa/inet.h>
#include <atomic>
#include <cstring>
#include <gtest/gtest.h>
#include <sys/socket.h>
#include <thread>
#include <unistd.h>

extern "C" {
#include "utils/udp.h"
}

// Fake RetroArch: answers the VERSION ping but never answers the command
// itself, like a RetroArch that is busy while saving.
TEST(Udp, SendReceiveDoesNotResendUnansweredCommand)
{
    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in addr = {};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    ASSERT_EQ(bind(fd, (struct sockaddr *)&addr, sizeof(addr)), 0);
    socklen_t len = sizeof(addr);
    getsockname(fd, (struct sockaddr *)&addr, &len);
    int port = ntohs(addr.sin_port);

    struct timeval tv = {0, 200000};
    setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    std::atomic<int> commands(0);
    std::atomic<bool> stop(false);
    std::thread server([&] {
        char buf[64];
        struct sockaddr_in from;
        while (!stop) {
            socklen_t from_len = sizeof(from);
            ssize_t n = recvfrom(fd, buf, sizeof(buf) - 1, 0, (struct sockaddr *)&from, &from_len);
            if (n <= 0)
                continue;
            buf[n] = '\0';
            if (strcmp(buf, "VERSION") == 0)
                sendto(fd, "1.0", 3, 0, (struct sockaddr *)&from, from_len);
            else
                commands++;
        }
    });

    char response[32];
    EXPECT_EQ(udp_send_receive("127.0.0.1", port, "SAVE_STATE_SLOT -1", response, sizeof(response)), -1);
    EXPECT_EQ(commands, 1);

    stop = true;
    server.join();
    close(fd);
}
