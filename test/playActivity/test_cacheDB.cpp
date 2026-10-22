#include "gtest/gtest.h"

#include <sqlite3/sqlite3.h>
#include <stdlib.h>
#include <string>
#include <sys/stat.h>

extern "C" {
#include "utils/file.h"
#include "utils/log.h"

#include "../../src/playActivity/cacheDB.h"
}

// Two ROMs with the same file name in different folders of one system must
// resolve to their own cache entry, not whichever row matches by name first.
TEST(CacheDB, FindPrefersExactPathOverSameName)
{
    char tmpl[] = "/tmp/onion-cachedb-test-XXXXXX";
    std::string root = mkdtemp(tmpl);
    std::string gba = root + "/Roms/GBA";
    mkdir((root + "/Roms").c_str(), 0777);
    mkdir(gba.c_str(), 0777);

    sqlite3 *db;
    ASSERT_EQ(sqlite3_open((gba + "/GBA_cache6.db").c_str(), &db), SQLITE_OK);
    std::string sql = "CREATE TABLE GBA_roms(disp TEXT, pinyin TEXT, path TEXT, imgpath TEXT);"
                      "INSERT INTO GBA_roms VALUES('Sonic', 'Sonic', '" +
                      gba + "/A-Z/Sonic.gba', 'a.png');"
                            "INSERT INTO GBA_roms VALUES('Sonic', 'Sonic', '" +
                      gba + "/Favourites/Sonic.gba', 'b.png');";
    ASSERT_EQ(sqlite3_exec(db, sql.c_str(), NULL, NULL, NULL), SQLITE_OK);
    sqlite3_close(db);

    std::string rom = gba + "/Favourites/Sonic.gba";
    CacheDBItem *item = cache_db_find(rom.c_str());
    ASSERT_NE(item, nullptr);
    EXPECT_EQ(std::string(item->path), rom);
    EXPECT_STREQ(item->imgpath, "b.png");
    free(item);

    system(("rm -rf " + root).c_str());
}
