-- TheRealDev.lua
-- GodMode9 Lua 5.4
-- A large utility menu with a 10-step button lock.

local APP_NAME = "TheRealDev"

-- ============================================================
-- CONFIGURATION
-- ============================================================

local LOCK_SEQUENCE = {
    "A",
    "LEFT",
    "B",
    "UP",
    "X",
    "RIGHT",
    "Y",
    "DOWN",
    "L",
    "R"
}

-- ============================================================
-- SCREEN HELPERS
-- ============================================================

local function screen(text)
    ui.clear()
    ui.show_text(text)
end

local function message(text)
    ui.echo(text)
end

-- Wait until a button is released.
local function wait_release()
    local keys = {
        "A", "B", "SELECT", "START",
        "RIGHT", "LEFT", "UP", "DOWN",
        "R", "L", "X", "Y"
    }

    while true do
        local pressed = false

        for _, key in ipairs(keys) do
            if ui.check_key(key) then
                pressed = true
                break
            end
        end

        if not pressed then
            return
        end
    end
end

-- Wait for a new button press.
local function wait_key()
    wait_release()

    while true do
        local keys = {
            "A", "B", "SELECT", "START",
            "RIGHT", "LEFT", "UP", "DOWN",
            "R", "L", "X", "Y"
        }

        for _, key in ipairs(keys) do
            if ui.check_key(key) then
                wait_release()
                return key
            end
        end
    end
end

-- ============================================================
-- 10-STEP LOCK
-- ============================================================

local function security_lock()
    local entered = {}

    screen(
        APP_NAME .. "\n\n" ..
        "SECURITY LOCK\n\n" ..
        "Enter the 10-button sequence.\n\n" ..
        "Required: 10 inputs\n" ..
        "Current: 0/10\n\n" ..
        "The required button is shown below.\n"
    )

    for i, required in ipairs(LOCK_SEQUENCE) do

        screen(
            APP_NAME .. "\n\n" ..
            "SECURITY LOCK\n\n" ..
            "Step " .. i .. "/10\n\n" ..
            "Required button:\n\n" ..
            "[ " .. required .. " ]\n\n" ..
            "Enter the button now.\n" ..
            "Wrong input = return to menu."
        )

        local key = wait_key()

        if key ~= required then
            screen(
                APP_NAME .. "\n\n" ..
                "SECURITY LOCK\n\n" ..
                "INCORRECT INPUT!\n\n" ..
                "Expected: " .. required .. "\n" ..
                "Received: " .. key .. "\n\n" ..
                "Returning to main menu..."
            )

            -- Give the user time to see the error.
            wait_key()
            return false
        end

        entered[#entered + 1] = key

        screen(
            APP_NAME .. "\n\n" ..
            "SECURITY LOCK\n\n" ..
            "Correct!\n\n" ..
            "Progress: " .. i .. "/10\n\n" ..
            "Input: " .. table.concat(entered, " -> ")
        )

        -- Prevent the same physical press from being
        -- interpreted twice.
        wait_release()
    end

    screen(
        APP_NAME .. "\n\n" ..
        "SECURITY LOCK\n\n" ..
        "ACCESS GRANTED\n\n" ..
        "All 10 inputs were correct.\n\n" ..
        "Press A to continue."
    )

    while not ui.check_key("A") do
    end

    wait_release()
    return true
end

-- ============================================================
-- SYSTEM INFORMATION
-- ============================================================

local function system_info()
    local text =
        APP_NAME .. "\n\n" ..
        "SYSTEM INFORMATION\n\n" ..
        "GodMode9: " .. tostring(GM9VER) .. "\n" ..
        "Console: " .. tostring(CONSOLE_TYPE) .. "\n" ..
        "Region: " .. tostring(sys.region) .. "\n" ..
        "Serial: " .. tostring(sys.serial) .. "\n" ..
        "SecureInfo: " .. tostring(sys.secureinfo_letter) .. "\n" ..
        "SysNAND ID0: " .. tostring(sys.sys_id0) .. "\n" ..
        "EmuNAND ID0: " .. tostring(sys.emu_id0) .. "\n" ..
        "EmuNAND Base: " .. tostring(sys.emu_base) .. "\n" ..
        "Gyro Model: " .. tostring(GYROMODEL) .. "\n" ..
        "Devkit: " .. tostring(IS_DEVKIT) .. "\n" ..
        "HAX: " .. tostring(HAX)

    ui.show_text_viewer(text)
end

-- ============================================================
-- SD INFORMATION
-- ============================================================

local function sd_info()
    local stat = fs.stat_fs("0:/")

    local text =
        APP_NAME .. "\n\n" ..
        "SD CARD INFORMATION\n\n" ..
        "Total: " .. ui.format_bytes(stat.total) .. "\n" ..
        "Used:  " .. ui.format_bytes(stat.used) .. "\n" ..
        "Free:  " .. ui.format_bytes(stat.free) .. "\n\n" ..
        "Filesystem: 0:/"

    ui.show_text_viewer(text)
end

-- ============================================================
-- GM9 DIRECTORY INFORMATION
-- ============================================================

local function gm9_info()
    local path = "0:/gm9"

    if not fs.exists(path) then
        message("The 0:/gm9 directory does not exist.")
        return
    end

    local info = fs.dir_info(path)

    local text =
        APP_NAME .. "\n\n" ..
        "GM9 DIRECTORY\n\n" ..
        "Path: " .. path .. "\n\n" ..
        "Directories: " .. tostring(info.dirs) .. "\n" ..
        "Files: " .. tostring(info.files) .. "\n" ..
        "Total size: " .. ui.format_bytes(info.size)

    ui.show_text_viewer(text)
end

-- ============================================================
-- FILE BROWSER
-- ============================================================

local function file_browser()
    local file = fs.ask_select_file(
        APP_NAME .. " - Select a file",
        "0:/gm9/*",
        {
            include_dirs = true,
            explorer = true
        }
    )

    if not file then
        return
    end

    local stat = fs.stat(file)

    local text =
        APP_NAME .. "\n\n" ..
        "SELECTED ITEM\n\n" ..
        "Name: " .. tostring(stat.name) .. "\n" ..
        "Type: " .. tostring(stat.type) .. "\n" ..
        "Size: " .. ui.format_bytes(stat.size) .. "\n" ..
        "Read only: " .. tostring(stat.read_only) .. "\n\n" ..
        "Path:\n" .. file

    ui.show_text_viewer(text)
end

-- ============================================================
-- TEXT VIEWER
-- ============================================================

local function text_viewer()
    local file = fs.ask_select_file(
        APP_NAME .. " - Select text file",
        "0:/gm9/*",
        {
            include_dirs = false,
            explorer = true
        }
    )

    if not file then
        return
    end

    ui.show_file_text_viewer(file)
end

-- ============================================================
-- FILE HASH
-- ============================================================

local function hash_file()
    local file = fs.ask_select_file(
        APP_NAME .. " - Select file to hash",
        "0:/gm9/*",
        {
            include_dirs = false,
            explorer = true
        }
    )

    if not file then
        return
    end

    local hash = fs.hash_file(file, 0, 0)

    local printable = util.bytes_to_hex(hash)

    ui.show_text_viewer(
        APP_NAME .. "\n\n" ..
        "SHA-256 HASH\n\n" ..
        "File:\n" .. file .. "\n\n" ..
        printable
    )
end

-- ============================================================
-- VERIFY FILE
-- ============================================================

local function verify_file()
    local file = fs.ask_select_file(
        APP_NAME .. " - Select file to verify",
        "0:/gm9/*",
        {
            include_dirs = false,
            explorer = true
        }
    )

    if not file then
        return
    end

    local result = fs.verify(file)

    if result then
        message(
            APP_NAME .. "\n\n" ..
            "VERIFICATION SUCCESSFUL\n\n" ..
            file
        )
    else
        message(
            APP_NAME .. "\n\n" ..
            "VERIFICATION FAILED\n\n" ..
            file
        )
    end
end

-- ============================================================
-- SHA FILE VERIFICATION
-- ============================================================

local function verify_sha()
    local file = fs.ask_select_file(
        APP_NAME .. " - Select file",
        "0:/gm9/*",
        {
            include_dirs = false,
            explorer = true
        }
    )

    if not file then
        return
    end

    local result = fs.verify_with_sha_file(file)

    if result == true then
        message("SHA-256 verification successful.")
    elseif result == false then
        message("SHA-256 verification FAILED.")
    else
        message("No corresponding .sha file could be read.")
    end
end

-- ============================================================
-- GAME INFORMATION
-- ============================================================

local function game_info()
    local file = fs.ask_select_file(
        APP_NAME .. " - Select game",
        "0:/gm9/*",
        {
            include_dirs = false,
            explorer = true
        }
    )

    if not file then
        return
    end

    ui.show_game_info(file)
end

-- ============================================================
-- KEY DUMP MENU
-- ============================================================

local function key_dump()
    local choice = ui.ask_selection(
        APP_NAME .. "\n\nKEY DUMP",
        {
            "Dump seeddb.bin",
            "Dump encrypted title keys",
            "Dump decrypted title keys",
            "Cancel"
        }
    )

    if not choice or choice == 4 then
        return
    end

    if choice == 1 then
        fs.key_dump("seeddb.bin")
        message("seeddb.bin created in 0:/gm9/out.")
    elseif choice == 2 then
        fs.key_dump("encTitleKeys.bin")
        message("encTitleKeys.bin created in 0:/gm9/out.")
    elseif choice == 3 then
        fs.key_dump("decTitleKeys.bin")
        message("decTitleKeys.bin created in 0:/gm9/out.")
    end
end

-- ============================================================
-- CIA BUILD
-- ============================================================

local function build_cia()
    local file = fs.ask_select_file(
        APP_NAME .. " - Select title",
        "0:/gm9/*",
        {
            include_dirs = false,
            explorer = true
        }
    )

    if not file then
        return
    end

    if not ui.ask(
        "Build a CIA from this title?\n\n" .. file
    ) then
        return
    end

    title.build_cia(file)

    message(
        "CIA build finished.\n\n" ..
        "Check 0:/gm9/out."
    )
end

-- ============================================================
-- TITLE INSTALL
-- ============================================================

local function install_title()
    local file = fs.ask_select_file(
        APP_NAME .. " - Select title to install",
        "0:/gm9/*",
        {
            include_dirs = false,
            explorer = true
        }
    )

    if not file then
        return
    end

    if not ui.ask(
        "Install this title?\n\n" .. file
    ) then
        return
    end

    title.install(file)

    message("Installation finished.")
end

-- ============================================================
-- IMAGE MOUNT
-- ============================================================

local function mount_image()
    local file = fs.ask_select_file(
        APP_NAME .. " - Select image",
        "0:/gm9/*",
        {
            include_dirs = false,
            explorer = true
        }
    )

    if not file then
        return
    end

    fs.img_mount(file)

    message(
        "Image mounted:\n\n" .. file
    )
end

-- ============================================================
-- UNMOUNT IMAGE
-- ============================================================

local function unmount_image()
    local mounted = fs.get_img_mount()

    if not mounted then
        message("No image is currently mounted.")
        return
    end

    if ui.ask(
        "Unmount this image?\n\n" .. mounted
    ) then
        fs.img_umount()
        message("Image unmounted.")
    end
end

-- ============================================================
-- FILE/DIRECTORY SEARCH
-- ============================================================

local function search_files()
    local path = fs.ask_select_dir(
        APP_NAME .. " - Select directory",
        "0:/",
        {
            explorer = true
        }
    )

    if not path then
        return
    end

    local pattern = ui.ask_text(
        "Enter filename pattern:",
        "*",
        128
    )

    if not pattern then
        return
    end

    local results = fs.find_all(
        path,
        pattern,
        {
            recursive = true
        }
    )

    local lines = {
        APP_NAME,
        "",
        "SEARCH RESULTS",
        "",
        "Directory: " .. path,
        "Pattern: " .. pattern,
        ""
    }

    for _, item in ipairs(results) do
        table.insert(
            lines,
            tostring(item)
        )
    end

    if #results == 0 then
        table.insert(lines, "No matching files found.")
    end

    ui.show_text_viewer(
        table.concat(lines, "\n")
    )
end

-- ============================================================
-- RAW CART DUMP
-- ============================================================

local function cart_dump()
    if not ui.ask(
        "Game Card Dump\n\n" ..
        "This reads data from the inserted game card.\n\n" ..
        "Continue?"
    ) then
        return
    end

    local size = ui.ask_number(
        "Enter dump size in bytes:",
        0
    )

    if not size or size <= 0 then
        message("Invalid size.")
        return
    end

    local output = fs.find_not(
        "0:/gm9/out/cart_??.bin"
    )

    fs.cart_dump(output, size)

    message(
        "Game Card dump finished.\n\n" ..
        output
    )
end

-- ============================================================
-- DATABASE CREATION
-- ============================================================

local function create_databases()
    local choice = ui.ask_selection(
        APP_NAME .. "\n\nCREATE DATABASE FILES",
        {
            "SysNAND CTRNAND (1:)",
            "EmuNAND CTRNAND (4:)",
            "SysNAND SD (A:)",
            "EmuNAND SD (B:)",
            "Cancel"
        }
    )

    if not choice or choice == 5 then
        return
    end

    local drives = {
        "1:",
        "4:",
        "A:",
        "B:"
    }

    local drive = drives[choice]

    if not ui.ask(
        "Create missing database files on " ..
        drive .. "?"
    ) then
        return
    end

    fs.create_dbs(drive)

    message(
        "Database operation finished."
    )
end

-- ============================================================
-- REBOOT / POWER
-- ============================================================

local function reboot()
    if ui.ask("Reboot the console?") then
        sys.reboot()
    end
end

local function poweroff()
    if ui.ask("Power off the console?") then
        sys.power_off()
    end
end

-- ============================================================
-- ABOUT
-- ============================================================

local function about()
    ui.show_text_viewer(
        APP_NAME .. "\n\n" ..
        "GodMode9 Lua Utility\n\n" ..
        "A large collection of utilities\n" ..
        "for GodMode9.\n\n" ..
        "Version: 1.0\n\n" ..
        "Security system: 10-step button lock\n\n" ..
        "Designed for GodMode9 Lua 5.4."
    )
end

-- ============================================================
-- MAIN MENU
-- ============================================================

local function main_menu()

    while true do

        local choice = ui.ask_selection(
            APP_NAME .. "\n\nMAIN MENU",
            {
                "System Information",
                "SD Card Information",
                "GM9 Directory Information",
                "File Browser",
                "Text Viewer",
                "SHA-256 File Hash",
                "Verify File",
                "Verify .sha File",
                "Game Information",
                "Key Dump",
                "Build CIA",
                "Install Title",
                "Mount Image",
                "Unmount Image",
                "Search Files",
                "Game Card Dump",
                "Create Database Files",
                "About TheRealDev",
                "Reboot",
                "Power Off",
                "Exit"
            }
        )

        if not choice then
            return
        end

        if choice == 1 then
            system_info()

        elseif choice == 2 then
            sd_info()

        elseif choice == 3 then
            gm9_info()

        elseif choice == 4 then
            file_browser()

        elseif choice == 5 then
            text_viewer()

        elseif choice == 6 then
            hash_file()

        elseif choice == 7 then
            verify_file()

        elseif choice == 8 then
            verify_sha()

        elseif choice == 9 then
            game_info()

        elseif choice == 10 then
            key_dump()

        elseif choice == 11 then
            build_cia()

        elseif choice == 12 then
            install_title()

        elseif choice == 13 then
            mount_image()

        elseif choice == 14 then
            unmount_image()

        elseif choice == 15 then
            search_files()

        elseif choice == 16 then
            cart_dump()

        elseif choice == 17 then
            create_databases()

        elseif choice == 18 then
            about()

        elseif choice == 19 then
            reboot()

        elseif choice == 20 then
            poweroff()

        elseif choice == 21 then
            return
        end
    end
end

-- ============================================================
-- PROGRAM START
-- ============================================================

screen(
    APP_NAME .. "\n\n" ..
    "Initializing...\n\n" ..
    "Security system enabled."
)

wait_key()

-- The lock is required before entering the utility menu.
security_lock()

-- Always return to the menu after a failed lock.
-- The script does not terminate because of an incorrect input.

while true do

    local unlocked = security_lock()

    if unlocked then
        main_menu()
        break
    end

    -- Failed attempt:
    -- show a small menu again.
    local retry = ui.ask_selection(
        APP_NAME .. "\n\nACCESS MENU",
        {
            "Try security lock again",
            "Exit"
        }
    )

    if retry ~= 1 then
        break
    end
end
