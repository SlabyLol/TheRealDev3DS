--[[
    TheRealDev.lua
    GodMode9 Lua 5.4
    Large multi-tool edition

    Location:
    0:/gm9/luascripts/TheRealDev.lua
]]

local NAME = "TheRealDev"
local VERSION = "2.0"

------------------------------------------------------------
-- BASIC HELPERS
------------------------------------------------------------

local function pause(text)
    ui.echo(text or "Press A to continue.")
end

local function safe(fn)
    local ok, err = pcall(fn)

    if not ok then
        ui.echo(
            "OPERATION ERROR\n\n" ..
            tostring(err) ..
            "\n\nPress A to return."
        )
        return false
    end

    return true
end

local function confirm(text)
    return ui.ask(text)
end

local function choose_file(prompt, pattern)
    return fs.ask_select_file(
        prompt,
        pattern or "0:/*",
        {
            include_dirs = false,
            explorer = true
        }
    )
end

local function choose_any(prompt)
    return fs.ask_select_file(
        prompt,
        "0:/*",
        {
            include_dirs = true,
            explorer = true
        }
    )
end

local function input(prompt, initial, max)
    return ui.ask_text(
        prompt,
        initial or "",
        max or 200
    )
end

------------------------------------------------------------
-- SYSTEM
------------------------------------------------------------

local function system_info()
    local s = fs.stat_fs("0:/")

    ui.show_text(
        "=== SYSTEM INFORMATION ===\n\n" ..
        "GodMode9: " .. tostring(GM9VER) .. "\n" ..
        "Console: " .. tostring(CONSOLE_TYPE) .. "\n" ..
        "Developer Unit: " .. tostring(IS_DEVKIT) .. "\n" ..
        "Region: " .. tostring(sys.region) .. "\n" ..
        "Serial: " .. tostring(sys.serial) .. "\n" ..
        "SecureInfo: " .. tostring(sys.secureinfo_letter) .. "\n" ..
        "SysNAND ID0: " .. tostring(sys.sys_id0) .. "\n" ..
        "EmuNAND ID0: " .. tostring(sys.emu_id0) .. "\n" ..
        "EmuNAND Base: " .. tostring(sys.emu_base) .. "\n" ..
        "Gyro Model: " .. tostring(GYROMODEL) .. "\n" ..
        "HAX: " .. tostring(HAX) .. "\n\n" ..
        "SD Total: " .. ui.format_bytes(s.total) .. "\n" ..
        "SD Used: " .. ui.format_bytes(s.used) .. "\n" ..
        "SD Free: " .. ui.format_bytes(s.free)
    )

    pause()
end

local function refresh_system()
    safe(function()
        sys.refresh_info()
        pause("System information refreshed.")
    end)
end

local function system_checks()
    while true do
        local c = ui.ask_selection(
            "SYSTEM CHECKS",
            {
                "Embedded Backup Check",
                "Raw RTC Check",
                "Refresh System Information",
                "System Information",
                "Back"
            }
        )

        if not c or c == 5 then
            return
        elseif c == 1 then
            safe(function()
                local r = sys.check_embedded_backup()

                if r == true then
                    pause("Embedded backup check passed.")
                elseif r == false then
                    pause("User declined the operation.")
                else
                    pause("Console failed the NCSD check.")
                end
            end)
        elseif c == 2 then
            safe(function()
                local r = sys.check_raw_rtc()

                if r then
                    pause("Raw RTC check passed.")
                else
                    pause("RTC check was declined.")
                end
            end)
        elseif c == 3 then
            refresh_system()
        elseif c == 4 then
            system_info()
        end
    end
end

------------------------------------------------------------
-- STORAGE
------------------------------------------------------------

local function storage_info()
    safe(function()
        local s = fs.stat_fs("0:/")

        ui.show_text(
            "=== SD STORAGE ===\n\n" ..
            "Total\n" ..
            ui.format_bytes(s.total) ..
            "\n\nUsed\n" ..
            ui.format_bytes(s.used) ..
            "\n\nFree\n" ..
            ui.format_bytes(s.free)
        )

        pause()
    end)
end

local function directory_info()
    local dir = fs.ask_select_dir(
        "Select directory",
        "0:/",
        { explorer = true }
    )

    if not dir then
        return
    end

    safe(function()
        local d = fs.dir_info(dir)

        ui.show_text(
            "=== DIRECTORY INFO ===\n\n" ..
            "Directory:\n" ..
            dir .. "\n\n" ..
            "Files: " .. tostring(d.files) .. "\n" ..
            "Directories: " .. tostring(d.dirs) .. "\n" ..
            "Size: " .. ui.format_bytes(d.size)
        )

        pause()
    end)
end

------------------------------------------------------------
-- FILE INFORMATION
------------------------------------------------------------

local function file_info()
    local path = choose_file("Select file")

    if not path then
        return
    end

    safe(function()
        local s = fs.stat(path)

        ui.show_text(
            "=== FILE INFORMATION ===\n\n" ..
            "Name: " .. tostring(s.name) .. "\n" ..
            "Type: " .. tostring(s.type) .. "\n" ..
            "Size: " .. ui.format_bytes(s.size) .. "\n" ..
            "Read-only: " .. tostring(s.read_only) .. "\n\n" ..
            "Path:\n" .. path
        )

        pause()
    end)
end

local function file_exists()
    local path = input(
        "Path to check:",
        "0:/",
        200
    )

    if not path then
        return
    end

    if fs.exists(path) then
        pause("EXISTS\n\n" .. path)
    else
        pause("DOES NOT EXIST\n\n" .. path)
    end
end

local function file_type()
    local path = choose_any("Select item")

    if not path then
        return
    end

    if fs.is_dir(path) then
        pause("This item is a DIRECTORY.")
    elseif fs.is_file(path) then
        pause("This item is a FILE.")
    else
        pause("The item could not be identified.")
    end
end

------------------------------------------------------------
-- SEARCH
------------------------------------------------------------

local function search_one()
    local pattern = input(
        "Search pattern:",
        "0:/",
        200
    )

    if not pattern then
        return
    end

    safe(function()
        local result = fs.find(
            pattern,
            { first = true }
        )

        if result then
            pause(
                "FOUND\n\n" ..
                result
            )
        else
            pause("NOT FOUND")
        end
    end)
end

local function search_all()
    local dir = fs.ask_select_dir(
        "Search directory",
        "0:/",
        { explorer = true }
    )

    if not dir then
        return
    end

    local pattern = input(
        "Filename pattern:",
        "*",
        100
    )

    if not pattern then
        return
    end

    safe(function()
        local results = fs.find_all(
            dir,
            pattern,
            { recursive = true }
        )

        local text =
            "=== SEARCH RESULTS ===\n\n"

        if #results == 0 then
            text = text .. "Nothing found."
        else
            for i, path in ipairs(results) do
                text = text ..
                    tostring(i) ..
                    ": " ..
                    tostring(path) ..
                    "\n"
            end
        end

        ui.show_text(text)
        pause()
    end)
end

local function free_filename()
    local pattern = input(
        "Filename pattern with ?:",
        "0:/file_??.bin",
        200
    )

    if not pattern then
        return
    end

    safe(function()
        local result = fs.find_not(pattern)

        pause(
            "AVAILABLE FILENAME:\n\n" ..
            result
        )
    end)
end

------------------------------------------------------------
-- FILE OPERATIONS
------------------------------------------------------------

local function copy_item()
    local src = choose_any("Select source")

    if not src then
        return
    end

    local dst = input(
        "Destination:",
        "0:/",
        200
    )

    if not dst then
        return
    end

    if not confirm(
        "COPY?\n\n" ..
        src .. "\n\nTO\n\n" ..
        dst
    ) then
        return
    end

    safe(function()
        fs.copy(src, dst, {
            recursive = true
        })

        pause("Copy completed.")
    end)
end

local function move_item()
    local src = choose_any("Select source")

    if not src then
        return
    end

    local dst = input(
        "Destination:",
        "0:/",
        200
    )

    if not dst then
        return
    end

    if not confirm(
        "MOVE?\n\n" ..
        src .. "\n\nTO\n\n" ..
        dst
    ) then
        return
    end

    safe(function()
        fs.move(src, dst)
        pause("Move completed.")
    end)
end

local function delete_item()
    local path = choose_any("Select item to delete")

    if not path then
        return
    end

    if not confirm(
        "WARNING!\n\n" ..
        "DELETE THIS ITEM?\n\n" ..
        path
    ) then
        return
    end

    safe(function()
        fs.remove(path, {
            recursive = true
        })

        pause("Delete completed.")
    end)
end

local function make_directory()
    local path = input(
        "Directory path:",
        "0:/NewFolder",
        200
    )

    if not path then
        return
    end

    safe(function()
        fs.mkdir(path)
        pause("Directory created.")
    end)
end

local function make_dummy()
    local path = input(
        "Dummy file:",
        "0:/dummy.bin",
        200
    )

    if not path then
        return
    end

    local size = ui.ask_number(
        "Size in bytes:",
        1024
    )

    if not size or size < 1 then
        return
    end

    safe(function()
        fs.make_dummy_file(path, size)
        pause("Dummy file created.")
    end)
end

local function truncate_file()
    local path = choose_file(
        "Select file",
        "0:/*"
    )

    if not path then
        return
    end

    local size = ui.ask_number(
        "New size in bytes:",
        0
    )

    if not size then
        return
    end

    if not confirm(
        "TRUNCATE FILE?\n\n" ..
        path .. "\n\n" ..
        "New size: " .. tostring(size)
    ) then
        return
    end

    safe(function()
        fs.truncate(path, size)
        pause("Truncate completed.")
    end)
end

------------------------------------------------------------
-- READ / WRITE
------------------------------------------------------------

local function text_viewer()
    local path = choose_file(
        "Select text file",
        "0:/*.txt"
    )

    if path then
        safe(function()
            ui.show_file_text_viewer(path)
        end)
    end
end

local function read_file()
    local path = choose_file(
        "Select file",
        "0:/*"
    )

    if not path then
        return
    end

    local size = ui.ask_number(
        "Bytes to read:",
        256
    )

    if not size or size < 1 then
        return
    end

    safe(function()
        local data = fs.read_file(
            path,
            0,
            size
        )

        ui.show_text(
            "=== RAW DATA ===\n\n" ..
            "Bytes: " .. tostring(#data) ..
            "\n\n" ..
            util.bytes_to_hex(data)
        )

        pause()
    end)
end

------------------------------------------------------------
-- HASH
------------------------------------------------------------

local function hash_sha256()
    local path = choose_file(
        "Select file",
        "0:/*"
    )

    if not path then
        return
    end

    safe(function()
        local data = fs.hash_file(
            path,
            0,
            0
        )

        ui.show_text(
            "=== SHA-256 ===\n\n" ..
            util.bytes_to_hex(data)
        )

        pause()
    end)
end

local function hash_sha1()
    local path = choose_file(
        "Select file",
        "0:/*"
    )

    if not path then
        return
    end

    safe(function()
        local data = fs.hash_file(
            path,
            0,
            0,
            { sha1 = true }
        )

        ui.show_text(
            "=== SHA-1 ===\n\n" ..
            util.bytes_to_hex(data)
        )

        pause()
    end)
end

local function hash_data()
    local text = input(
        "Data to hash:",
        "",
        500
    )

    if not text then
        return
    end

    safe(function()
        local hash = fs.hash_data(text)

        ui.show_text(
            "=== DATA SHA-256 ===\n\n" ..
            util.bytes_to_hex(hash)
        )

        pause()
    end)
end

local function verify_file()
    local path = choose_file(
        "Select file",
        "0:/*"
    )

    if not path then
        return
    end

    safe(function()
        if fs.verify(path) then
            pause("VERIFICATION PASSED")
        else
            pause("VERIFICATION FAILED\nor file is not verifiable.")
        end
    end)
end

local function verify_sha()
    local path = choose_file(
        "Select file",
        "0:/*"
    )

    if not path then
        return
    end

    safe(function()
        local r = fs.verify_with_sha_file(path)

        if r == true then
            pause("SHA-256 CHECK PASSED")
        elseif r == false then
            pause("SHA-256 CHECK FAILED")
        else
            pause("SHA FILE COULD NOT BE READ")
        end
    end)
end

------------------------------------------------------------
-- TITLE / CIA
------------------------------------------------------------

local function build_cia()
    local path = choose_file(
        "Select title",
        "0:/*"
    )

    if not path then
        return
    end

    if not confirm(
        "BUILD CIA?\n\n" .. path
    ) then
        return
    end

    safe(function()
        title.build_cia(path)
        pause(
            "CIA BUILD COMPLETE\n\n" ..
            "Output:\n0:/gm9/out"
        )
    end)
end

local function build_legit_cia()
    local path = choose_file(
        "Select title",
        "0:/*"
    )

    if not path then
        return
    end

    if not confirm(
        "BUILD LEGIT CIA IF POSSIBLE?\n\n" ..
        path
    ) then
        return
    end

    safe(function()
        title.build_cia(path, {
            legit = true
        })

        pause("CIA operation completed.")
    end)
end

local function install_title()
    local path = choose_file(
        "Select title to install",
        "0:/*"
    )

    if not path then
        return
    end

    if not confirm(
        "INSTALL TITLE?\n\n" ..
        path
    ) then
        return
    end

    safe(function()
        title.install(path)
        pause("Installation completed.")
    end)
end

local function install_emunand()
    local path = choose_file(
        "Select title",
        "0:/*"
    )

    if not path then
        return
    end

    if not confirm(
        "INSTALL TO EMUNAND?\n\n" ..
        path
    ) then
        return
    end

    safe(function()
        title.install(path, {
            to_emunand = true
        })

        pause("EmuNAND installation completed.")
    end)
end

local function encrypt_title()
    local path = choose_file(
        "Select title/database",
        "0:/*"
    )

    if not path then
        return
    end

    if confirm(
        "ENCRYPT IN PLACE?\n\n" .. path
    ) then
        safe(function()
            title.encrypt(path)
            pause("Encryption completed.")
        end)
    end
end

local function decrypt_title()
    local path = choose_file(
        "Select title/database",
        "0:/*"
    )

    if not path then
        return
    end

    if confirm(
        "DECRYPT IN PLACE?\n\n" .. path
    ) then
        safe(function()
            title.decrypt(path)
            pause("Decryption completed.")
        end)
    end
end

------------------------------------------------------------
-- PATCHES
------------------------------------------------------------

local function patch(kind)
    local extension = string.lower(kind)

    local patch_file = choose_file(
        "Select " .. kind .. " patch",
        "0:/*." .. extension
    )

    if not patch_file then
        return
    end

    local source = choose_file(
        "Select source file",
        "0:/*"
    )

    if not source then
        return
    end

    local target = input(
        "Target file:",
        "0:/patched.bin",
        200
    )

    if not target then
        return
    end

    if not confirm(
        "APPLY " .. kind .. " PATCH?"
    ) then
        return
    end

    safe(function()
        if kind == "IPS" then
            title.apply_ips(
                patch_file,
                source,
                target
            )
        elseif kind == "BPS" then
            title.apply_bps(
                patch_file,
                source,
                target
            )
        else
            title.apply_bpm(
                patch_file,
                source,
                target
            )
        end

        pause("Patch completed.")
    end)
end

------------------------------------------------------------
-- CODE
------------------------------------------------------------

local function extract_code()
    local source = choose_file(
        "Select title/code source",
        "0:/*"
    )

    if not source then
        return
    end

    local destination = input(
        "Destination:",
        "0:/gm9/out/code.bin",
        200
    )

    if not destination then
        return
    end

    safe(function()
        title.extract_code(
            source,
            destination
        )

        pause("Code extraction completed.")
    end)
end

local function compress_code()
    local source = choose_file(
        "Select extracted code",
        "0:/*"
    )

    if not source then
        return
    end

    local destination = input(
        "Destination:",
        "0:/gm9/out/code.compressed",
        200
    )

    if not destination then
        return
    end

    safe(function()
        title.compress_code(
            source,
            destination
        )

        pause("Code compression completed.")
    end)
end

------------------------------------------------------------
-- KEYS
------------------------------------------------------------

local function dump_key(file)
    if not confirm(
        "CREATE " .. file .. "?\n\n" ..
        "Output: 0:/gm9/out"
    ) then
        return
    end

    safe(function()
        fs.key_dump(file)
        pause(
            file ..
            "\n\ncreated in 0:/gm9/out"
        )
    end)
end

------------------------------------------------------------
-- DATABASES
------------------------------------------------------------

local function create_database(drive)
    if not confirm(
        "CREATE DATABASES ON\n\n" ..
        drive .. "?"
    ) then
        return
    end

    safe(function()
        fs.create_dbs(drive)
        pause(
            "Database operation completed."
        )
    end)
end

------------------------------------------------------------
-- CARTRIDGE
------------------------------------------------------------

local function cart_dump()
    local size = ui.ask_number(
        "Dump size in bytes:",
        0
    )

    if not size or size <= 0 then
        pause("Invalid size.")
        return
    end

    local output = input(
        "Output path:",
        "0:/gm9/out/cart.bin",
        200
    )

    if not output then
        return
    end

    if not confirm(
        "DUMP GAME CARD?\n\n" ..
        "Size: " .. tostring(size)
    ) then
        return
    end

    safe(function()
        fs.cart_dump(
            output,
            size
        )

        pause("Cartridge dump completed.")
    end)
end

------------------------------------------------------------
-- IMAGE MOUNT
------------------------------------------------------------

local function mount_image()
    local path = choose_file(
        "Select image",
        "0:/*"
    )

    if not path then
        return
    end

    safe(function()
        fs.img_mount(path)
        pause(
            "Mounted:\n\n" .. path
        )
    end)
end

local function mounted_image()
    safe(function()
        local path = fs.get_img_mount()

        if path then
            pause(
                "CURRENT IMAGE:\n\n" .. path
            )
        else
            pause("No image is mounted.")
        end
    end)
end

local function unmount_image()
    if not confirm(
        "UNMOUNT CURRENT IMAGE?"
    ) then
        return
    end

    safe(function()
        fs.img_umount()
        pause("Image unmounted.")
    end)
end

------------------------------------------------------------
-- SD SWITCH
------------------------------------------------------------

local function switch_sd()
    if confirm(
        "Switch the SD card now?"
    ) then
        safe(function()
            fs.sd_switch(
                "Please switch the SD card now."
            )
        end)
    end
end

------------------------------------------------------------
-- LED TOOLS
------------------------------------------------------------

local function led_tools()
    while true do
        local c = ui.ask_selection(
            "LED TOOLS",
            {
                "Power LED Normal",
                "Power LED Fade Blue",
                "Power LED Sleep",
                "Power LED Off",
                "Power LED Red",
                "Power LED Blue",
                "Power LED Blink Red",
                "Back"
            }
        )

        if not c or c == 8 then
            return
        end

        local states = {
            0, 1, 2, 3, 4, 5, 6
        }

        safe(function()
            i2c.write(
                i2c.dev.MCU,
                i2c.mcu.reg.POWER_LED_STATE,
                { states[c] }
            )

            pause("LED state changed.")
        end)
    end
end

------------------------------------------------------------
-- I2C / HARDWARE INFO
------------------------------------------------------------

local function hardware_info()
    safe(function()
        local power = i2c.read(
            i2c.dev.MCU,
            i2c.mcu.reg.POWER_STATUS,
            1
        )

        local battery = i2c.read(
            i2c.dev.MCU,
            i2c.mcu.reg.BATTERY_PERCENTAGE_INT,
            1
        )

        local voltage = i2c.read(
            i2c.dev.MCU,
            i2c.mcu.reg.BATTERY_VOLTAGE,
            1
        )

        local volume = i2c.read(
            i2c.dev.MCU,
            i2c.mcu.reg.VOLUME_SLIDER_RAW,
            1
        )

        ui.show_text(
            "=== HARDWARE INFO ===\n\n" ..
            "Battery: " ..
            tostring(battery[1]) .. "%\n" ..
            "Voltage raw: " ..
            tostring(voltage[1]) .. "\n" ..
            "Volume raw: " ..
            tostring(volume[1]) .. "\n" ..
            "Power status: " ..
            tostring(power[1]) .. "\n" ..
            "Gyro model: " ..
            tostring(GYROMODEL)
        )

        pause()
    end)
end

------------------------------------------------------------
-- EMUNAND
------------------------------------------------------------

local function next_emunand()
    if not confirm(
        "Switch to the next available EmuNAND?"
    ) then
        return
    end

    safe(function()
        sys.next_emu()
        pause(
            "EmuNAND switched.\n\n" ..
            "Current base: " ..
            tostring(sys.emu_base)
        )
    end)
end

------------------------------------------------------------
-- BACKUP / OUTPUT DIRECTORY
------------------------------------------------------------

local function ensure_output()
    safe(function()
        if not fs.exists("0:/gm9/out") then
            fs.mkdir("0:/gm9/out")
        end

        pause(
            "Output directory checked:\n\n" ..
            "0:/gm9/out"
        )
    end)
end

------------------------------------------------------------
-- TEXT / QR
------------------------------------------------------------

local function custom_text()
    local text = input(
        "Text to display:",
        "TheRealDev",
        1000
    )

    if text then
        safe(function()
            ui.show_text_viewer(text)
        end)
    end
end

local function qr_code()
    local prompt = input(
        "QR prompt:",
        "TheRealDev",
        100
    )

    if not prompt then
        return
    end

    local data = input(
        "QR data:",
        "",
        1000
    )

    if not data then
        return
    end

    safe(function()
        ui.show_qr(
            prompt,
            data
        )
    end)
end

------------------------------------------------------------
-- 10 STEP LOCK
------------------------------------------------------------

local LOCK = {
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

local function release(key)
    while ui.check_key(key) do
    end
end

local function lock_step(step, key)
    -- Bottom screen prompt.
    -- ui.echo displays on the bottom screen.
    ui.echo(
        "THE REAL DEV LOCK\n\n" ..
        "Step " .. tostring(step) .. " / 10\n\n" ..
        "Press: " .. key
    )
end

local function wait_lock()
    for step, expected in ipairs(LOCK) do

        lock_step(
            step,
            expected
        )

        while true do
            local pressed = nil

            for _, key in ipairs({
                "A",
                "B",
                "X",
                "Y",
                "L",
                "R",
                "LEFT",
                "RIGHT",
                "UP",
                "DOWN",
                "START",
                "SELECT"
            }) do
                if ui.check_key(key) then
                    pressed = key
                    break
                end
            end

            if pressed then
                if pressed ~= expected then
                    release(pressed)

                    ui.echo(
                        "WRONG INPUT!\n\n" ..
                        "Returning to menu."
                    )

                    return false
                end

                release(pressed)
                break
            end
        end
    end

    ui.echo(
        "ACCESS GRANTED!\n\n" ..
        "10 / 10 correct."
    )

    return true
end

------------------------------------------------------------
-- SUBMENUS
------------------------------------------------------------

local function file_menu()
    while true do
        local c = ui.ask_selection(
            "FILE MANAGER",
            {
                "File Information",
                "Check Exists",
                "File / Directory Type",
                "Copy",
                "Move",
                "Delete",
                "Create Directory",
                "Create Dummy File",
                "Truncate File",
                "Directory Information",
                "Find One",
                "Find All",
                "Find Free Filename",
                "Text Viewer",
                "Read Raw Data",
                "Back"
            }
        )

        if not c or c == 16 then
            return
        elseif c == 1 then file_info()
        elseif c == 2 then file_exists()
        elseif c == 3 then file_type()
        elseif c == 4 then copy_item()
        elseif c == 5 then move_item()
        elseif c == 6 then delete_item()
        elseif c == 7 then make_directory()
        elseif c == 8 then make_dummy()
        elseif c == 9 then truncate_file()
        elseif c == 10 then directory_info()
        elseif c == 11 then search_one()
        elseif c == 12 then search_all()
        elseif c == 13 then free_filename()
        elseif c == 14 then text_viewer()
        elseif c == 15 then read_file()
        end
    end
end

local function hash_menu()
    while true do
        local c = ui.ask_selection(
            "HASH & VERIFY",
            {
                "SHA-256 File",
                "SHA-1 File",
                "SHA-256 Data",
                "Verify File",
                "Verify .sha",
                "Back"
            }
        )

        if not c or c == 6 then
            return
        elseif c == 1 then hash_sha256()
        elseif c == 2 then hash_sha1()
        elseif c == 3 then hash_data()
        elseif c == 4 then verify_file()
        elseif c == 5 then verify_sha()
        end
    end
end

local function title_menu()
    while true do
        local c = ui.ask_selection(
            "TITLE / CIA TOOLS",
            {
                "Build CIA",
                "Build Legit CIA",
                "Install Title",
                "Install to EmuNAND",
                "Encrypt",
                "Decrypt",
                "Back"
            }
        )

        if not c or c == 7 then
            return
        elseif c == 1 then build_cia()
        elseif c == 2 then build_legit_cia()
        elseif c == 3 then install_title()
        elseif c == 4 then install_emunand()
        elseif c == 5 then encrypt_title()
        elseif c == 6 then decrypt_title()
        end
    end
end

local function patch_menu()
    while true do
        local c = ui.ask_selection(
            "PATCH TOOLS",
            {
                "Apply IPS",
                "Apply BPS",
                "Apply BPM",
                "Back"
            }
        )

        if not c or c == 4 then
            return
        elseif c == 1 then patch("IPS")
        elseif c == 2 then patch("BPS")
        elseif c == 3 then patch("BPM")
        end
    end
end

local function code_menu()
    while true do
        local c = ui.ask_selection(
            "CODE TOOLS",
            {
                "Extract Code",
                "Compress Code",
                "Back"
            }
        )

        if not c or c == 3 then
            return
        elseif c == 1 then extract_code()
        elseif c == 2 then compress_code()
        end
    end
end

local function key_menu()
    while true do
        local c = ui.ask_selection(
            "KEY TOOLS",
            {
                "seeddb.bin",
                "encTitleKeys.bin",
                "decTitleKeys.bin",
                "Back"
            }
        )

        if not c or c == 4 then
            return
        elseif c == 1 then
            dump_key("seeddb.bin")
        elseif c == 2 then
            dump_key("encTitleKeys.bin")
        elseif c == 3 then
            dump_key("decTitleKeys.bin")
        end
    end
end

local function database_menu()
    while true do
        local c = ui.ask_selection(
            "DATABASE TOOLS",
            {
                "SysNAND CTRNAND (1:)",
                "EmuNAND CTRNAND (4:)",
                "SysNAND SD (A:)",
                "EmuNAND SD (B:)",
                "Back"
            }
        )

        if not c or c == 5 then
            return
        elseif c == 1 then create_database("1:")
        elseif c == 2 then create_database("4:")
        elseif c == 3 then create_database("A:")
        elseif c == 4 then create_database("B:")
        end
    end
end

local function mount_menu()
    while true do
        local c = ui.ask_selection(
            "IMAGE TOOLS",
            {
                "Mount Image",
                "Current Mount",
                "Unmount Image",
                "Back"
            }
        )

        if not c or c == 4 then
            return
        elseif c == 1 then mount_image()
        elseif c == 2 then mounted_image()
        elseif c == 3 then unmount_image()
        end
    end
end

local function utilities_menu()
    while true do
        local c = ui.ask_selection(
            "UTILITIES",
            {
                "System Checks",
                "Storage Information",
                "Switch SD Card",
                "Ensure gm9/out",
                "Text Viewer",
                "Custom Text",
                "QR Code",
                "Hardware Information",
                "Switch EmuNAND",
                "Reboot",
                "Power Off",
                "Back"
            }
        )

        if not c or c == 12 then
            return
        elseif c == 1 then system_checks()
        elseif c == 2 then storage_info()
        elseif c == 3 then switch_sd()
        elseif c == 4 then ensure_output()
        elseif c == 5 then text_viewer()
        elseif c == 6 then custom_text()
        elseif c == 7 then qr_code()
        elseif c == 8 then hardware_info()
        elseif c == 9 then next_emunand()
        elseif c == 10 then
            if confirm("REBOOT CONSOLE?") then
                safe(function()
                    sys.reboot()
                end)
            end
        elseif c == 11 then
            if confirm("POWER OFF CONSOLE?") then
                safe(function()
                    sys.power_off()
                end)
            end
        end
    end
end

------------------------------------------------------------
-- ABOUT
------------------------------------------------------------

local function about()
    ui.show_text(
        "=== TheRealDev ===\n\n" ..
        "Version " .. VERSION .. "\n\n" ..
        "Large GodMode9 Lua utility.\n\n" ..
        "Features include:\n" ..
        "- File management\n" ..
        "- Search\n" ..
        "- Hashing\n" ..
        "- Verification\n" ..
        "- CIA tools\n" ..
        "- Patch tools\n" ..
        "- Code tools\n" ..
        "- Key tools\n" ..
        "- Database tools\n" ..
        "- Cartridge tools\n" ..
        "- Image mounting\n" ..
        "- Hardware information\n" ..
        "- LED controls\n" ..
        "- 10-step lock\n\n" ..
        "No FTP/network API is used."
    )

    pause()
end

------------------------------------------------------------
-- MAIN MENU
------------------------------------------------------------

while true do

    local c = ui.ask_selection(
        "THE REAL DEV v" .. VERSION,
        {
            "System Information",
            "File Manager",
            "Hash & Verify",
            "Title / CIA Tools",
            "Patch Tools",
            "Code Tools",
            "Key Tools",
            "Database Tools",
            "Cartridge Dump",
            "Image Tools",
            "LED Tools",
            "Utilities",
            "Storage Information",
            "10-Step Lock",
            "About TheRealDev",
            "Exit"
        }
    )

    if not c or c == 16 then
        break

    elseif c == 1 then
        system_info()

    elseif c == 2 then
        file_menu()

    elseif c == 3 then
        hash_menu()

    elseif c == 4 then
        title_menu()

    elseif c == 5 then
        patch_menu()

    elseif c == 6 then
        code_menu()

    elseif c == 7 then
        key_menu()

    elseif c == 8 then
        database_menu()

    elseif c == 9 then
        cart_dump()

    elseif c == 10 then
        mount_menu()

    elseif c == 11 then
        led_tools()

    elseif c == 12 then
        utilities_menu()

    elseif c == 13 then
        storage_info()

    elseif c == 14 then
        wait_lock()

    elseif c == 15 then
        about()
    end
end
