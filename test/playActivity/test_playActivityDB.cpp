#include "gtest/gtest.h"

#include <sqlite3/sqlite3.h>
#include <stdlib.h>
#include <string>
#include <sys/stat.h>
#include <vector>

extern "C" {
#include "utils/file.h"
#include "utils/log.h"

#define PLAY_ACTIVITY_DB_NEW_FILE "/tmp/onion-play-activity-test.sqlite"
#define PLAY_ACTIVITY_STATES_DIR "/tmp/onion-play-activity-states"
#include "../../src/playActivity/playActivityDB.h"
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

// cache6 `pinyin` is an ASCII sort key; the displayed name must come from
// `disp` so CJK/accented titles survive (#34)
TEST(CacheDB, FindReturnsDisplayNameNotPinyin)
{
    char tmpl[] = "/tmp/onion-cachedb-test-XXXXXX";
    std::string root = mkdtemp(tmpl);
    std::string gba = root + "/Roms/GBA";
    mkdir((root + "/Roms").c_str(), 0777);
    mkdir(gba.c_str(), 0777);

    sqlite3 *db;
    ASSERT_EQ(sqlite3_open((gba + "/GBA_cache6.db").c_str(), &db), SQLITE_OK);
    std::string sql = "CREATE TABLE GBA_roms(disp TEXT, pinyin TEXT, path TEXT, imgpath TEXT);"
                      "INSERT INTO GBA_roms VALUES('\xE6\x98\x9F\xE4\xB9\x8B Pok\xC3\xA9mon', 'xz Pok mon', '" +
                      gba + "/a.gba', '');";
    ASSERT_EQ(sqlite3_exec(db, sql.c_str(), NULL, NULL, NULL), SQLITE_OK);
    sqlite3_close(db);

    CacheDBItem *item = cache_db_find((gba + "/a.gba").c_str());
    ASSERT_NE(item, nullptr);
    EXPECT_STREQ(item->name, "\xE6\x98\x9F\xE4\xB9\x8B Pok\xC3\xA9mon");
    free(item);

    system(("rm -rf " + root).c_str());
}

static int count_rows(const char *sql)
{
    int n = -1;
    play_activity_db_open();
    sqlite3_stmt *stmt = play_activity_db_prepare(sql);
    if (sqlite3_step(stmt) == SQLITE_ROW)
        n = sqlite3_column_int(stmt, 0);
    sqlite3_finalize(stmt);
    play_activity_db_close();
    return n;
}

// easyRPG games are folders whose cache row path differs from the launched
// path; every launch must reuse the same rom row (#31).
TEST(PlayActivityDB, RelaunchReusesRomWhenCachePathDiffers)
{
    char tmpl[] = "/tmp/onion-easyrpg-test-XXXXXX";
    std::string root = mkdtemp(tmpl);
    std::string sys = root + "/Roms/EASYRPG";
    std::string game = sys + "/Yume Nikki";
    mkdir((root + "/Roms").c_str(), 0777);
    mkdir(sys.c_str(), 0777);
    mkdir(game.c_str(), 0777);
    remove(PLAY_ACTIVITY_DB_NEW_FILE);

    sqlite3 *db;
    ASSERT_EQ(sqlite3_open((sys + "/EASYRPG_cache6.db").c_str(), &db), SQLITE_OK);
    std::string sql = "CREATE TABLE EASYRPG_roms(disp TEXT, pinyin TEXT, path TEXT, imgpath TEXT);"
                      "INSERT INTO EASYRPG_roms VALUES('Yume Nikki', 'Yume Nikki', '" +
                      game + "/RPG_RT.ini', '');";
    ASSERT_EQ(sqlite3_exec(db, sql.c_str(), NULL, NULL, NULL), SQLITE_OK);
    sqlite3_close(db);

    std::vector<char> path(game.begin(), game.end());
    path.push_back('\0');
    play_activity_start(path.data());
    play_activity_stop(path.data());
    play_activity_start(path.data());

    EXPECT_EQ(count_rows("SELECT COUNT(*) FROM rom;"), 1);
    EXPECT_EQ(count_rows("SELECT COUNT(DISTINCT rom_id) FROM play_activity;"), 1);
    EXPECT_EQ(count_rows("SELECT COUNT(*) FROM play_activity;"), 2);

    remove(PLAY_ACTIVITY_DB_NEW_FILE);
    system(("rm -rf " + root).c_str());
}

// A cover that is not at Roms/<system>/Imgs falls back to the cached imgpath,
// and resolving it must not truncate the rom's file_path (#32).
TEST(PlayActivityDB, ImagePathFallsBackToCachedImage)
{
    char tmpl[] = "/tmp/onion-img-test-XXXXXX";
    std::string root = mkdtemp(tmpl);
    std::string img = root + "/cover.png";
    fclose(fopen(img.c_str(), "w"));

    char rom_file[] = "GBA/Sub/Foo.gba";
    char out[STR_MAX];

    get_rom_image_path(rom_file, img.c_str(), out);
    EXPECT_EQ(std::string(out), img);
    EXPECT_STREQ(rom_file, "GBA/Sub/Foo.gba");

    get_rom_image_path(rom_file, "", out);
    EXPECT_STREQ(out, "/mnt/SDCARD/Roms/GBA/Imgs/Foo.png");

    get_rom_image_path("", NULL, out);
    EXPECT_STREQ(out, "");

    system(("rm -rf " + root).c_str());
}

// Without box art, the auto save state thumbnail of any core is used (#47).
TEST(PlayActivityDB, ImagePathFallsBackToStateThumbnail)
{
    std::string root = PLAY_ACTIVITY_STATES_DIR;
    system(("rm -rf " + root).c_str());
    mkdir(root.c_str(), 0777);
    mkdir((root + "/gpSP").c_str(), 0777);
    mkdir((root + "/mGBA").c_str(), 0777);
    std::string thumb = root + "/mGBA/Foo.state.auto.png";
    fclose(fopen(thumb.c_str(), "w"));

    char out[STR_MAX];

    get_rom_image_path("GBA/Foo.gba", NULL, out);
    EXPECT_EQ(std::string(out), thumb);

    // No thumbnail: keep the (missing) Imgs path as before.
    get_rom_image_path("GBA/Bar.gba", NULL, out);
    EXPECT_STREQ(out, "/mnt/SDCARD/Roms/GBA/Imgs/Bar.png");

    system(("rm -rf " + root).c_str());
}
