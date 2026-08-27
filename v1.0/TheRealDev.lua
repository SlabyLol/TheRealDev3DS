-- ============================================================
-- TheRealDev.lua
-- GodMode9 Lua 5.4
--
-- Large utility menu
-- 10-button security locks for sensitive operations
-- ============================================================

local APP_NAME = "TheRealDev"
local VERSION = "1.0"

-- ============================================================
-- CONFIGURATION
-- ============================================================

local NORMAL_LOCK = {
    "A",
    "LEFT",
    "B",
    "RIGHT",
    "UP",
    "DOWN",
    "L",
    "R",
    "X",
    "Y"
}

local DANGER_LOCK = {
    "LEFT",
    "A",
    "DOWN",
    "B",
    "RIGHT",
    "L",
    "UP",
    "R",
    "X",
    "Y"
}

local EXTREME_LOCK = {
    "R",
    "UP",
    "A",
    "LEFT",
    "Y",
    "DOWN",
    "B",
    "RIGHT",
    "L",
    "X"
}

-- ============================================================
-- HELPERS
-- ============================================================

local ALL_KEYS = {
    "A", "B",
    "X", "Y",
    "L", "R",
    "START", "SELECT",
    "UP", "DOWN", "LEFT", "RIGHT"
}

local function wait_release()
    while true do
        local held = false

        for _, key in ipairs(ALL_KEYS) do
            if ui.check_key(key) then
                held = true
                break
            end
        end

        if not held then
            return
        end
    end
end

local function wait_key()
    while true do
        for _, key in ipairs(ALL_KEYS) do
            if ui.check_key(key) then
                wait_release()
                return key
            end
        end
    end
end

local function message(text)
    ui.echo(
        APP_NAME .. "\n\n" ..
        text
    )
end

local function separator()
    return "\n\n------------------------------\n\n"
end

-- ============================================================
-- SECURITY LOCK
-- ============================================================

local function security_lock(title, sequence)

    message(
        "SECURITY LOCK\n\n" ..
        title .. "\n\n" ..
        "10-button verification required.\n\n" ..
        "Press A to begin."
    )

    for i = 1, #sequence do

        local expected = sequence[i]

        -- ui.echo is the supported GM9 prompt mechanism.
        -- ui.check_key performs the actual key detection.
        message(
            "SECURITY LOCK\n\n" ..
            title .. "\n\n" ..
            "STEP " .. i .. " / " .. #sequence ..
            "\n\n" ..
            "NEXT BUTTON:\n\n" ..
            expected .. "\n\n" ..
            "Wrong input = MAIN MENU"
        )

        local key = wait_key()

        if key ~= expected then

            message(
                "ACCESS DENIED\n\n" ..
                "Incorrect button.\n\n" ..
                "Returning to main menu."
            )

            return false
        end
    end

    message(
        "ACCESS GRANTED\n\n" ..
        "Security sequence accepted."
    )

    return true
end

local function danger_lock(title)
    return security_lock(title, DANGER_LOCK)
end

local function extreme_lock(title)
    return security_lock(title, EXTREME_LOCK)
end

-- ============================================================
-- SYSTEM INFORMATION
-- ============================================================

local function system_information()

    local region = sys.region or "Unknown"
    local serial = sys.serial or "Unknown"
    local id0 = sys.sys_id0 or "Unknown"

    message(
        "SYSTEM INFORMATION\n\n" ..
        "GodMode9: " .. tostring(GM9VER) .. "\n" ..
        "Console: " .. tostring(CONSOLE_TYPE) .. "\n" ..
        "Region: " .. region .. "\n" ..
        "Serial: " .. serial .. "\n\n" ..
        "SysNAND ID0:\n" ..
        id0
    )
end

local function emunand_information()

    local id0 = sys.emu_id0 or "None"
    local base = sys.emu_base or 0

    message(
        "EMUNAND INFORMATION\n\n" ..
        "EmuNAND ID0:\n" ..
        id0 .. "\n\n" ..
        "Base: " .. tostring(base)
    )
end

local function console_information()

    message(
        "CONSOLE INFORMATION\n\n" ..
        "Type: " .. tostring(CONSOLE_TYPE) .. "\n" ..
        "Devkit: " .. tostring(IS_DEVKIT) .. "\n" ..
        "Gyro model: " .. tostring(GYROMODEL) .. "\n" ..
        "HAX: " .. tostring(HAX)
    )
end

local function date_time()

    message(
        "DATE / TIME\n\n" ..
        "Date: " .. util.get_datestamp() .. "\n" ..
        "Time: " .. util.get_timestamp()
    )
end

-- ============================================================
-- STORAGE INFORMATION
-- ============================================================

local function sd_information()

    local stat = fs.stat_fs("0:/")

    message(
        "SD CARD INFORMATION\n\n" ..
        "Total:\n" ..
        ui.format_bytes(stat.total) .. "\n\n" ..
        "Used:\n" ..
        ui.format_bytes(stat.used) .. "\n\n" ..
        "Free:\n" ..
        ui.format_bytes(stat.free)
    )
end

local function directory_information()

    local path = fs.ask_select_dir(
        "Select directory",
        "0:/",
        { explorer = true }
    )

    if not path then
        return
    end

    local info = fs.dir_info(path)

    message(
        "DIRECTORY INFORMATION\n\n" ..
        "Path:\n" .. path .. "\n\n" ..
        "Files: " .. tostring(info.files) .. "\n" ..
        "Directories: " .. tostring(info.dirs) .. "\n" ..
        "Size: " .. ui.format_bytes(info.size)
    )
end

local function file_information()

    local path = fs.ask_select_file(
        "Select file",
        "0:/*",
        { include_dirs = false, explorer = true }
    )

    if not path then
        return
    end

    local stat = fs.stat(path)

    message(
        "FILE INFORMATION\n\n" ..
        "Name:\n" .. stat.name .. "\n\n" ..
        "Type: " .. stat.type .. "\n" ..
        "Size: " .. ui.format_bytes(stat.size) .. "\n" ..
        "Read only: " .. tostring(stat.read_only) .. "\n\n" ..
        "Path:\n" .. path
    )
end

-- ============================================================
-- FILE TOOLS
-- ============================================================

local function browse_files()

    local path = fs.ask_select_file(
        "FILE BROWSER",
        "0:/*",
        { include_dirs = true, explorer = true }
    )

    if not path then
        return
    end

    message(
        "SELECTED ITEM\n\n" ..
        path
    )
end

local function find_files()

    local pattern = ui.ask_text(
        "Search pattern",
        "*",
        100
    )

    if not pattern then
        return
    end

    local results = fs.find_all(
        "0:/",
        pattern,
        { recursive = true }
    )

    local text = "SEARCH RESULTS\n\n"

    if #results == 0 then
        text = text .. "No files found."
    else
        for i, path in ipairs(results) do
            text = text ..
                tostring(i) .. ". " ..
                tostring(path) .. "\n"
        end
    end

    ui.show_text_viewer(text)
end

local function hash_file()

    local path = fs.ask_select_file(
        "Select file to hash",
        "0:/*",
        { include_dirs = false, explorer = true }
    )

    if not path then
        return
    end

    local hash = fs.hash_file(path, 0, 0)
    local hex = util.bytes_to_hex(hash)

    ui.show_text_viewer(
        "SHA-256\n\n" ..
        path .. "\n\n" ..
        hex
    )
end

local function verify_file()

    local path = fs.ask_select_file(
        "Select file to verify",
        "0:/*",
        { include_dirs = false, explorer = true }
    )

    if not path then
        return
    end

    local result = fs.verify(path)

    if result then
        message(
            "VERIFY RESULT\n\n" ..
            "SUCCESS\n\n" ..
            path
        )
    else
        message(
            "VERIFY RESULT\n\n" ..
            "FAILED / NOT VERIFIABLE\n\n" ..
            path
        )
    end
end

local function verify_sha()

    local path = fs.ask_select_file(
        "Select file",
        "0:/*",
        { include_dirs = false, explorer = true }
    )

    if not path then
        return
    end

    local result = fs.verify_with_sha_file(path)

    if result == true then
        message("SHA-256 CHECK\n\nMATCH")
    elseif result == false then
        message("SHA-256 CHECK\n\nMISMATCH")
    else
        message("SHA-256 CHECK\n\nSHA FILE NOT FOUND")
    end
end

-- ============================================================
-- QR / TEXT
-- ============================================================

local function qr_tool()

    local text = ui.ask_text(
        "QR title",
        "TheRealDev",
        100
    )

    if not text then
        return
    end

    local data = ui.ask_text(
        "QR data",
        "",
        500
    )

    if not data then
        return
    end

    ui.show_qr(text, data)
end

local function text_viewer()

    local path = fs.ask_select_file(
        "Select text file",
        "0:/*",
        { include_dirs = false, explorer = true }
    )

    if not path then
        return
    end

    ui.show_file_text_viewer(path)
end

-- ============================================================
-- GAME / TITLE TOOLS
-- ============================================================

local function build_cia()

    if not danger_lock("BUILD CIA") then
        return
    end

    local path = fs.ask_select_file(
        "Select title",
        "0:/*",
        { include_dirs = false, explorer = true }
    )

    if not path then
        return
    end

    title.build_cia(path)

    message(
        "CIA BUILD\n\n" ..
        "Finished.\n\n" ..
        "Output:\n0:/gm9/out"
    )
end

local function extract_code()

    if not danger_lock("EXTRACT CODE") then
        return
    end

    local src = fs.ask_select_file(
        "Select title",
        "0:/*",
        { include_dirs = false, explorer = true }
    )

    if not src then
        return
    end

    local dst = ui.ask_text(
        "Destination",
        "0:/gm9/out/extracted.code",
        200
    )

    if not dst then
        return
    end

    title.extract_code(src, dst)

    message(
        "CODE EXTRACTION\n\n" ..
        "Completed.\n\n" ..
        dst
    )
end

local function compress_code()

    if not danger_lock("COMPRESS CODE") then
        return
    end

    local src = fs.ask_select_file(
        "Select .code",
        "0:/*",
        { include_dirs = false, explorer = true }
    )

    if not src then
        return
    end

    local dst = ui.ask_text(
        "Destination",
        "0:/gm9/out/compressed.code",
        200
    )

    if not dst then
        return
    end

    title.compress_code(src, dst)

    message(
        "CODE COMPRESSION\n\n" ..
        "Completed."
    )
end

-- ============================================================
-- PATCHING
-- ============================================================

local function patch_menu()

    local choice = ui.ask_selection(
        "PATCH TYPE",
        {
            "IPS",
            "BPS",
            "BPM",
            "Cancel"
        }
    )

    if not choice or choice == 4 then
        return
    end

    if not danger_lock("PATCH OPERATION") then
        return
    end

    local patch = fs.ask_select_file(
        "Select patch",
        "0:/*",
        { include_dirs = false, explorer = true }
    )

    if not patch then
        return
    end

    local src = fs.ask_select_file(
        "Select source",
        "0:/*",
        { include_dirs = false, explorer = true }
    )

    if not src then
        return
    end

    local target = ui.ask_text(
        "Output path",
        "0:/gm9/out/patched.bin",
        200
    )

    if not target then
        return
    end

    if choice == 1 then
        title.apply_ips(patch, src, target)
    elseif choice == 2 then
        title.apply_bps(patch, src, target)
    elseif choice == 3 then
        title.apply_bpm(patch, src, target)
    end

    message(
        "PATCH COMPLETE\n\n" ..
        target
    )
end

-- ============================================================
-- KEY DUMP
-- ============================================================

local function key_dump()

    if not danger_lock("KEY DUMP") then
        return
    end

    local choice = ui.ask_selection(
        "KEY DUMP",
        {
            "seeddb.bin",
            "encTitleKeys.bin",
            "decTitleKeys.bin",
            "Cancel"
        }
    )

    if not choice or choice == 4 then
        return
    end

    local files = {
        "seeddb.bin",
        "encTitleKeys.bin",
        "decTitleKeys.bin"
    }

    fs.key_dump(files[choice])

    message(
        "KEY DUMP COMPLETE\n\n" ..
        "Output:\n0:/gm9/out/" ..
        files[choice]
    )
end

-- ============================================================
-- MOUNTED IMAGE
-- ============================================================

local function mounted_image()

    local path = fs.get_img_mount()

    if path then
        message(
            "MOUNTED IMAGE\n\n" ..
            path
        )
    else
        message(
            "MOUNTED IMAGE\n\n" ..
            "No image is mounted."
        )
    end
end

local function mount_image()

    local path = fs.ask_select_file(
        "Select image",
        "0:/*",
        { include_dirs = false, explorer = true }
    )

    if not path then
        return
    end

    fs.img_mount(path)

    message(
        "IMAGE MOUNTED\n\n" ..
        path
    )
end

local function unmount_image()

    fs.img_umount()

    message(
        "IMAGE\n\n" ..
        "Unmounted."
    )
end

-- ============================================================
-- GAME CARD
-- ============================================================

local function cart_dump()

    if not extreme_lock("GAME CARD DUMP") then
        return
    end

    local size = ui.ask_number(
        "Dump size in bytes",
        0
    )

    if not size or size <= 0 then
        return
    end

    local path = ui.ask_text(
        "Output file",
        "0:/gm9/out/cart.bin",
        200
    )

    if not path then
        return
    end

    fs.cart_dump(path, size)

    message(
        "GAME CARD DUMP\n\n" ..
        "Finished.\n\n" ..
        path
    )
end

-- ============================================================
-- DATABASE
-- ============================================================

local function create_databases()

    if not extreme_lock("CREATE DATABASES") then
        return
    end

    local drive = ui.ask_text(
        "Destination drive",
        "A:",
        10
    )

    if not drive then
        return
    end

    fs.create_dbs(drive)

    message(
        "DATABASES\n\n" ..
        "Operation completed."
    )
end

-- ============================================================
-- SAFE FILE COPY
-- ============================================================

local function copy_file()

    local src = fs.ask_select_file(
        "Select source",
        "0:/*",
        { include_dirs = true, explorer = true }
    )

    if not src then
        return
    end

    local dst = ui.ask_text(
        "Destination",
        "0:/gm9/out/",
        200
    )

    if not dst then
        return
    end

    fs.copy(src, dst)

    message(
        "COPY COMPLETE\n\n" ..
        src .. "\n\n->\n\n" ..
        dst
    )
end

-- ============================================================
-- DELETE
-- ============================================================

local function delete_file()

    if not extreme_lock("DELETE FILE") then
        return
    end

    local path = fs.ask_select_file(
        "Select item to delete",
        "0:/*",
        { include_dirs = false, explorer = true }
    )

    if not path then
        return
    end

    local confirmed = ui.ask(
        "Delete this file?\n\n" .. path
    )

    if not confirmed then
        return
    end

    fs.remove(path)

    message(
        "DELETE COMPLETE\n\n" ..
        path
    )
end

-- ============================================================
-- POWER MENU
-- ============================================================

local function power_menu()

    local choice = ui.ask_selection(
        "POWER",
        {
            "Reboot",
            "Power Off",
            "Cancel"
        }
    )

    if not choice or choice == 3 then
        return
    end

    if not danger_lock("POWER CONTROL") then
        return
    end

    if choice == 1 then
        sys.reboot()
    elseif choice == 2 then
        sys.power_off()
    end
end

-- ============================================================
-- HARDWARE INFORMATION
-- ============================================================

local function hardware_information()

    local voltage = i2c.read(
        i2c.dev.MCU,
        i2c.mcu.reg.BATTERY_VOLTAGE,
        1
    )

    local battery = i2c.read(
        i2c.dev.MCU,
        i2c.mcu.reg.BATTERY_PERCENTAGE_INT,
        1
    )

    local power = i2c.read(
        i2c.dev.MCU,
        i2c.mcu.reg.POWER_STATUS,
        1
    )

    message(
        "HARDWARE INFORMATION\n\n" ..
        "Battery: " .. tostring(battery[1]) .. "%\n" ..
        "Voltage raw: " .. tostring(voltage[1]) .. "\n" ..
        "Power status: " .. tostring(power[1]) .. "\n\n" ..
        "Gyro model: " .. tostring(GYROMODEL)
    )
end

-- ============================================================
-- MAIN MENUS
-- ============================================================

local function system_menu()

    while true do

        local c = ui.ask_selection(
            APP_NAME .. " / SYSTEM",
            {
                "System Information",
                "Console Information",
                "EmuNAND Information",
                "Date / Time",
                "Hardware Information",
                "Back"
            }
        )

        if not c or c == 6 then
            return
        elseif c == 1 then
            system_information()
        elseif c == 2 then
            console_information()
        elseif c == 3 then
            emunand_information()
        elseif c == 4 then
            date_time()
        elseif c == 5 then
            hardware_information()
        end
    end
end

local function storage_menu()

    while true do

        local c = ui.ask_selection(
            APP_NAME .. " / STORAGE",
            {
                "SD Card Information",
                "Browse Files",
                "File Information",
                "Directory Information",
                "Find Files",
                "Hash File",
                "Verify File",
                "Verify SHA",
                "Copy File",
                "Delete File [LOCKED]",
                "Back"
            }
        )

        if not c or c == 11 then
            return
        elseif c == 1 then
            sd_information()
        elseif c == 2 then
            browse_files()
        elseif c == 3 then
            file_information()
        elseif c == 4 then
            directory_information()
        elseif c == 5 then
            find_files()
        elseif c == 6 then
            hash_file()
        elseif c == 7 then
            verify_file()
        elseif c == 8 then
            verify_sha()
        elseif c == 9 then
            copy_file()
        elseif c == 10 then
            delete_file()
        end
    end
end

local function title_menu()

    while true do

        local c = ui.ask_selection(
            APP_NAME .. " / TITLES",
            {
                "Build CIA [LOCKED]",
                "Extract Code [LOCKED]",
                "Compress Code [LOCKED]",
                "Apply Patch [LOCKED]",
                "Key Dump [LOCKED]",
                "Game Card Dump [LOCKED]",
                "Back"
            }
        )

        if not c or c == 7 then
            return
        elseif c == 1 then
            build_cia()
        elseif c == 2 then
            extract_code()
        elseif c == 3 then
            compress_code()
        elseif c == 4 then
            patch_menu()
        elseif c == 5 then
            key_dump()
        elseif c == 6 then
            cart_dump()
        end
    end
end

local function utility_menu()

    while true do

        local c = ui.ask_selection(
            APP_NAME .. " / UTILITIES",
            {
                "QR Generator",
                "Text Viewer",
                "Mounted Image",
                "Mount Image",
                "Unmount Image",
                "Create Databases [LOCKED]",
                "Back"
            }
        )

        if not c or c == 7 then
            return
        elseif c == 1 then
            qr_tool()
        elseif c == 2 then
            text_viewer()
        elseif c == 3 then
            mounted_image()
        elseif c == 4 then
            mount_image()
        elseif c == 5 then
            unmount_image()
        elseif c == 6 then
            create_databases()
        end
    end
end

local function power_section()
    power_menu()
end

-- ============================================================
-- MAIN PROGRAM
-- ============================================================

while true do

    local choice = ui.ask_selection(
        APP_NAME .. " v" .. VERSION,
        {
            "System",
            "Storage",
            "Titles / Games",
            "Utilities",
            "Power",
            "Exit"
        }
    )

    if not choice or choice == 6 then
        break
    elseif choice == 1 then
        system_menu()
    elseif choice == 2 then
        storage_menu()
    elseif choice == 3 then
        title_menu()
    elseif choice == 4 then
        utility_menu()
    elseif choice == 5 then
        power_section()
    end
end
