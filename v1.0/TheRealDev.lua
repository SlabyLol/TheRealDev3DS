-- TheRealDev.lua
-- GodMode9 Lua 5.4
-- Safe multi-tool menu
--
-- Put this file in:
-- 0:/gm9/luascripts/TheRealDev.lua

local APP_NAME = "TheRealDev"
local VERSION = "1.0"

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function wait_a()
    ui.echo("Press A to continue.")
end

local function confirm(text)
    return ui.ask(text)
end

local function show_error(message)
    ui.echo("ERROR\n\n" .. tostring(message))
end

local function safe_call(fn)
    local ok, err = pcall(fn)

    if not ok then
        show_error(err)
        return false
    end

    return true
end

local function select_file(prompt, pattern)
    local path = fs.ask_select_file(prompt, pattern, {
        include_dirs = false,
        explorer = true
    })

    return path
end

local function select_dir(prompt, path)
    return fs.ask_select_dir(prompt, path, {
        explorer = true
    })
end

------------------------------------------------------------
-- Main menu
------------------------------------------------------------

local function main_menu()
    return ui.ask_selection(
        APP_NAME .. " v" .. VERSION,
        {
            "System Information",
            "SD Card Information",
            "File Tools",
            "Hash & Verify",
            "Title / CIA Tools",
            "Patch Tools",
            "Code Tools",
            "Key Tools",
            "Database Tools",
            "Cartridge Tools",
            "LED Tools",
            "Utilities",
            "10-Step Lock Test",
            "About TheRealDev",
            "Exit"
        }
    )
end

------------------------------------------------------------
-- System information
------------------------------------------------------------

local function system_information()
    local text = "SYSTEM INFORMATION\n\n"

    text = text .. "GodMode9: " .. tostring(GM9VER) .. "\n"
    text = text .. "Console: " .. tostring(CONSOLE_TYPE) .. "\n"
    text = text .. "Devkit: " .. tostring(IS_DEVKIT) .. "\n"
    text = text .. "Region: " .. tostring(sys.region) .. "\n"
    text = text .. "Serial: " .. tostring(sys.serial) .. "\n"
    text = text .. "SecureInfo: " .. tostring(sys.secureinfo_letter) .. "\n"
    text = text .. "SysNAND ID0: " .. tostring(sys.sys_id0) .. "\n"
    text = text .. "EmuNAND ID0: " .. tostring(sys.emu_id0) .. "\n"
    text = text .. "EmuNAND base: " .. tostring(sys.emu_base) .. "\n"
    text = text .. "Gyro model: " .. tostring(GYROMODEL) .. "\n"
    text = text .. "HAX: " .. tostring(HAX) .. "\n"
    text = text .. "Script: " .. tostring(SCRIPT)

    ui.show_text(text)
    wait_a()
end

------------------------------------------------------------
-- SD information
------------------------------------------------------------

local function sd_information()
    safe_call(function()
        local s = fs.stat_fs("0:/")

        local text = "SD CARD INFORMATION\n\n"
        text = text .. "Total: " .. ui.format_bytes(s.total) .. "\n"
        text = text .. "Used:  " .. ui.format_bytes(s.used) .. "\n"
        text = text .. "Free:  " .. ui.format_bytes(s.free)

        ui.show_text(text)
        wait_a()
    end)
end

------------------------------------------------------------
-- File tools
------------------------------------------------------------

local function copy_file()
    local src = select_file(
        "Select file to COPY",
        "0:/*"
    )

    if not src then
        return
    end

    local dst = ui.ask_text(
        "Destination path:",
        "0:/",
        200
    )

    if not dst then
        return
    end

    if not confirm(
        "COPY FILE?\n\n" ..
        src .. "\n\nTO\n\n" ..
        dst
    ) then
        return
    end

    safe_call(function()
        fs.copy(src, dst, {
            overwrite = false
        })

        ui.echo("Copy completed.")
    end)
end

local function move_file()
    local src = select_file(
        "Select file to MOVE",
        "0:/*"
    )

    if not src then
        return
    end

    local dst = ui.ask_text(
        "Destination path:",
        "0:/",
        200
    )

    if not dst then
        return
    end

    if not confirm(
        "MOVE FILE?\n\n" ..
        src .. "\n\nTO\n\n" ..
        dst
    ) then
        return
    end

    safe_call(function()
        fs.move(src, dst)
        ui.echo("Move completed.")
    end)
end

local function delete_file()
    local path = select_file(
        "Select file to DELETE",
        "0:/*"
    )

    if not path then
        return
    end

    if not confirm(
        "WARNING!\n\nDELETE THIS FILE?\n\n" ..
        path
    ) then
        return
    end

    safe_call(function()
        fs.remove(path)
        ui.echo("File deleted.")
    end)
end

local function create_directory()
    local path = ui.ask_text(
        "New directory path:",
        "0:/",
        200
    )

    if not path then
        return
    end

    safe_call(function()
        fs.mkdir(path)
        ui.echo("Directory created.")
    end)
end

local function file_information()
    local path = select_file(
        "Select a file",
        "0:/*"
    )

    if not path then
        return
    end

    safe_call(function()
        local s = fs.stat(path)

        ui.show_text(
            "FILE INFORMATION\n\n" ..
            "Name: " .. tostring(s.name) .. "\n" ..
            "Type: " .. tostring(s.type) .. "\n" ..
            "Size: " .. ui.format_bytes(s.size) .. "\n" ..
            "Read-only: " .. tostring(s.read_only)
        )

        wait_a()
    end)
end

local function find_file()
    local pattern = ui.ask_text(
        "Search pattern:",
        "0:/",
        200
    )

    if not pattern then
        return
    end

    safe_call(function()
        local result = fs.find(pattern, {
            first = true
        })

        if result then
            ui.show_text(
                "SEARCH RESULT\n\n" ..
                result
            )
        else
            ui.show_text(
                "SEARCH RESULT\n\n" ..
                "Nothing found."
            )
        end

        wait_a()
    end)
end

local function file_tools()
    while true do
        local choice = ui.ask_selection(
            "FILE TOOLS",
            {
                "Copy",
                "Move",
                "Delete",
                "Create Directory",
                "File Information",
                "Find File",
                "Back"
            }
        )

        if not choice or choice == 7 then
            return
        elseif choice == 1 then
            copy_file()
        elseif choice == 2 then
            move_file()
        elseif choice == 3 then
            delete_file()
        elseif choice == 4 then
            create_directory()
        elseif choice == 5 then
            file_information()
        elseif choice == 6 then
            find_file()
        end
    end
end

------------------------------------------------------------
-- Hash & Verify
------------------------------------------------------------

local function hash_file()
    local path = select_file(
        "Select file to HASH",
        "0:/*"
    )

    if not path then
        return
    end

    safe_call(function()
        local hash = fs.hash_file(path, 0, 0)
        local hex = util.bytes_to_hex(hash)

        ui.show_text(
            "SHA-256\n\n" ..
            path .. "\n\n" ..
            hex
        )

        wait_a()
    end)
end

local function verify_file()
    local path = select_file(
        "Select file to VERIFY",
        "0:/*"
    )

    if not path then
        return
    end

    safe_call(function()
        local result = fs.verify(path)

        if result then
            ui.echo("Verification successful.")
        else
            ui.echo("Verification failed or file is not verifiable.")
        end
    end)
end

local function verify_sha()
    local path = select_file(
        "Select file with .sha",
        "0:/*"
    )

    if not path then
        return
    end

    safe_call(function()
        local result = fs.verify_with_sha_file(path)

        if result == true then
            ui.echo("SHA-256 verification successful.")
        elseif result == false then
            ui.echo("SHA-256 verification failed.")
        else
            ui.echo("Could not read the .sha file.")
        end
    end)
end

local function hash_verify()
    while true do
        local choice = ui.ask_selection(
            "HASH & VERIFY",
            {
                "SHA-256 File Hash",
                "Verify File",
                "Verify .sha File",
                "Back"
            }
        )

        if not choice or choice == 4 then
            return
        elseif choice == 1 then
            hash_file()
        elseif choice == 2 then
            verify_file()
        elseif choice == 3 then
            verify_sha()
        end
    end
end

------------------------------------------------------------
-- Title / CIA
------------------------------------------------------------

local function build_cia()
    local path = select_file(
        "Select title to build as CIA",
        "0:/*"
    )

    if not path then
        return
    end

    if not confirm(
        "Build CIA from:\n\n" ..
        path .. "?"
    ) then
        return
    end

    safe_call(function()
        title.build_cia(path)
        ui.echo("CIA build completed.\n\nCheck:\n0:/gm9/out")
    end)
end

local function install_title()
    local path = select_file(
        "Select title to install",
        "0:/*"
    )

    if not path then
        return
    end

    if not confirm(
        "INSTALL THIS TITLE?\n\n" ..
        path
    ) then
        return
    end

    safe_call(function()
        title.install(path)
        ui.echo("Installation completed.")
    end)
end

local function decrypt_title()
    local path = select_file(
        "Select title/database to decrypt",
        "0:/*"
    )

    if not path then
        return
    end

    if not confirm(
        "DECRYPT IN PLACE?\n\n" ..
        path
    ) then
        return
    end

    safe_call(function()
        title.decrypt(path)
        ui.echo("Decryption completed.")
    end)
end

local function encrypt_title()
    local path = select_file(
        "Select title/database to encrypt",
        "0:/*"
    )

    if not path then
        return
    end

    if not confirm(
        "ENCRYPT IN PLACE?\n\n" ..
        path
    ) then
        return
    end

    safe_call(function()
        title.encrypt(path)
        ui.echo("Encryption completed.")
    end)
end

local function title_tools()
    while true do
        local choice = ui.ask_selection(
            "TITLE / CIA TOOLS",
            {
                "Build CIA",
                "Install Title",
                "Decrypt",
                "Encrypt",
                "Back"
            }
        )

        if not choice or choice == 5 then
            return
        elseif choice == 1 then
            build_cia()
        elseif choice == 2 then
            install_title()
        elseif choice == 3 then
            decrypt_title()
        elseif choice == 4 then
            encrypt_title()
        end
    end
end

------------------------------------------------------------
-- Patch tools
------------------------------------------------------------

local function apply_patch(kind)
    local patch = select_file(
        "Select " .. kind .. " patch",
        "0:/*." .. string.lower(kind)
    )

    if not patch then
        return
    end

    local src = select_file(
        "Select source file",
        "0:/ *"
    )

    if not src then
        return
    end

    local dst = ui.ask_text(
        "Output file:",
        "0:/patched.bin",
        200
    )

    if not dst then
        return
    end

    if not confirm(
        "Apply " .. kind .. " patch?"
    ) then
        return
    end

    safe_call(function()
        if kind == "IPS" then
            title.apply_ips(patch, src, dst)
        elseif kind == "BPS" then
            title.apply_bps(patch, src, dst)
        elseif kind == "BPM" then
            title.apply_bpm(patch, src, dst)
        end

        ui.echo("Patch operation completed.")
    end)
end

local function patch_tools()
    while true do
        local choice = ui.ask_selection(
            "PATCH TOOLS",
            {
                "Apply IPS",
                "Apply BPS",
                "Apply BPM",
                "Back"
            }
        )

        if not choice or choice == 4 then
            return
        elseif choice == 1 then
            apply_patch("IPS")
        elseif choice == 2 then
            apply_patch("BPS")
        elseif choice == 3 then
            apply_patch("BPM")
        end
    end
end

------------------------------------------------------------
-- Code tools
------------------------------------------------------------

local function extract_code()
    local src = select_file(
        "Select source containing .code",
        "0:/*"
    )

    if not src then
        return
    end

    local dst = ui.ask_text(
        "Destination .code:",
        "0:/code.bin",
        200
    )

    if not dst then
        return
    end

    safe_call(function()
        title.extract_code(src, dst)
        ui.echo("Code extracted.")
    end)
end

local function compress_code()
    local src = select_file(
        "Select extracted .code",
        "0:/*"
    )

    if not src then
        return
    end

    local dst = ui.ask_text(
        "Destination:",
        "0:/code.compressed",
        200
    )

    if not dst then
        return
    end

    safe_call(function()
        title.compress_code(src, dst)
        ui.echo("Code compressed.")
    end)
end

local function code_tools()
    while true do
        local choice = ui.ask_selection(
            "CODE TOOLS",
            {
                "Extract Code",
                "Compress Code",
                "Back"
            }
        )

        if not choice or choice == 3 then
            return
        elseif choice == 1 then
            extract_code()
        elseif choice == 2 then
            compress_code()
        end
    end
end

------------------------------------------------------------
-- Key tools
------------------------------------------------------------

local function key_tools()
    while true do
        local choice = ui.ask_selection(
            "KEY TOOLS",
            {
                "Dump seeddb.bin",
                "Dump encTitleKeys.bin",
                "Dump decTitleKeys.bin",
                "Back"
            }
        )

        if not choice or choice == 4 then
            return
        elseif choice == 1 then
            safe_call(function()
                fs.key_dump("seeddb.bin")
                ui.echo("seeddb.bin created in 0:/gm9/out")
            end)
        elseif choice == 2 then
            safe_call(function()
                fs.key_dump("encTitleKeys.bin")
                ui.echo("encTitleKeys.bin created in 0:/gm9/out")
            end)
        elseif choice == 3 then
            safe_call(function()
                fs.key_dump("decTitleKeys.bin")
                ui.echo("decTitleKeys.bin created in 0:/gm9/out")
            end)
        end
    end
end

------------------------------------------------------------
-- Database tools
------------------------------------------------------------

local function database_tools()
    local choice = ui.ask_selection(
        "DATABASE TOOLS",
        {
            "Create SysNAND CTRNAND DBs",
            "Create EmuNAND CTRNAND DBs",
            "Create SysNAND SD DBs",
            "Create EmuNAND SD DBs",
            "Back"
        }
    )

    if not choice or choice == 5 then
        return
    end

    local drive

    if choice == 1 then
        drive = "1:"
    elseif choice == 2 then
        drive = "4:"
    elseif choice == 3 then
        drive = "A:"
    elseif choice == 4 then
        drive = "B:"
    end

    if not confirm(
        "Create/recreate databases on " ..
        drive .. "?"
    ) then
        return
    end

    safe_call(function()
        fs.create_dbs(drive)
        ui.echo("Database operation completed.")
    end)
end

------------------------------------------------------------
-- Cartridge tools
------------------------------------------------------------

local function cartridge_dump()
    local size = ui.ask_number(
        "Cartridge dump size in bytes:",
        0
    )

    if not size or size <= 0 then
        ui.echo("Invalid size.")
        return
    end

    local dst = ui.ask_text(
        "Output file:",
        "0:/gm9/out/cart.bin",
        200
    )

    if not dst then
        return
    end

    if not confirm(
        "DUMP GAME CARD?\n\n" ..
        "Size: " .. tostring(size) .. " bytes"
    ) then
        return
    end

    safe_call(function()
        fs.cart_dump(dst, size)
        ui.echo("Cartridge dump completed.")
    end)
end

------------------------------------------------------------
-- LED tools
------------------------------------------------------------

local function led_tools()
    while true do
        local choice = ui.ask_selection(
            "LED TOOLS",
            {
                "Power LED: Blue",
                "Power LED: Red",
                "Power LED: Off",
                "Power LED: Normal",
                "Back"
            }
        )

        if not choice or choice == 5 then
            return
        end

        safe_call(function()
            if choice == 1 then
                i2c.write(
                    i2c.dev.MCU,
                    i2c.mcu.reg.POWER_LED_STATE,
                    {5}
                )
            elseif choice == 2 then
                i2c.write(
                    i2c.dev.MCU,
                    i2c.mcu.reg.POWER_LED_STATE,
                    {4}
                )
            elseif choice == 3 then
                i2c.write(
                    i2c.dev.MCU,
                    i2c.mcu.reg.POWER_LED_STATE,
                    {3}
                )
            elseif choice == 4 then
                i2c.write(
                    i2c.dev.MCU,
                    i2c.mcu.reg.POWER_LED_STATE,
                    {0}
                )
            end

            ui.echo("LED operation completed.")
        end)
    end
end

------------------------------------------------------------
-- Utilities
------------------------------------------------------------

local function utilities()
    while true do
        local choice = ui.ask_selection(
            "UTILITIES",
            {
                "Text Viewer",
                "QR Code",
                "Refresh System Info",
                "Switch SD Card",
                "Reboot",
                "Power Off",
                "Back"
            }
        )

        if not choice or choice == 7 then
            return
        elseif choice == 1 then
            local path = select_file(
                "Select text file",
                "0:/*.txt"
            )

            if path then
                safe_call(function()
                    ui.show_file_text_viewer(path)
                end)
            end

        elseif choice == 2 then
            local text = ui.ask_text(
                "QR prompt:",
                "TheRealDev",
                100
            )

            if text then
                local data = ui.ask_text(
                    "QR data:",
                    "",
                    500
                )

                if data then
                    safe_call(function()
                        ui.show_qr(text, data)
                    end)
                end
            end

        elseif choice == 3 then
            safe_call(function()
                sys.refresh_info()
                ui.echo("System information refreshed.")
            end)

        elseif choice == 4 then
            safe_call(function()
                fs.sd_switch()
            end)

        elseif choice == 5 then
            if confirm("REBOOT THE CONSOLE?") then
                safe_call(function()
                    sys.reboot()
                end)
            end

        elseif choice == 6 then
            if confirm("POWER OFF THE CONSOLE?") then
                safe_call(function()
                    sys.power_off()
                end)
            end
        end
    end
end

------------------------------------------------------------
-- 10-step lock
--
-- Important:
-- ui.check_key() reports currently-held keys.
-- We wait for release after every successful step so that
-- one physical press cannot accidentally count twice.
------------------------------------------------------------

local LOCK_SEQUENCE = {
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

local function wait_for_release(key)
    while ui.check_key(key) do
    end
end

local function wait_for_any_lock_key()
    while true do
        for _, key in ipairs(LOCK_SEQUENCE) do
            if ui.check_key(key) then
                return key
            end
        end
    end
end

local function lock_screen(step, expected)
    ui.show_text(
        "LOCK SYSTEM\n\n" ..
        "Step " .. tostring(step) .. " / 10"
    )

    -- This is deliberately displayed on the bottom screen.
    ui.echo(
        "LOCK SYSTEM\n\n" ..
        "Step " .. tostring(step) .. " / 10\n\n" ..
        "Press: " .. expected
    )
end

local function ten_step_lock()
    for step, expected in ipairs(LOCK_SEQUENCE) do
        lock_screen(step, expected)

        local pressed = wait_for_any_lock_key()

        if pressed ~= expected then
            ui.echo(
                "WRONG INPUT\n\n" ..
                "Returning to main menu."
            )
            wait_a()

            return false
        end

        wait_for_release(pressed)
    end

    ui.echo(
        "ACCESS GRANTED\n\n" ..
        "The 10-step sequence is correct."
    )

    return true
end

------------------------------------------------------------
-- About
------------------------------------------------------------

local function about()
    ui.show_text(
        "TheRealDev\n\n" ..
        "Version " .. VERSION .. "\n\n" ..
        "A multi-purpose GodMode9 Lua utility.\n\n" ..
        "Designed around the documented\n" ..
        "GodMode9 Lua API.\n\n" ..
        "No FTP / network functions are used."
    )

    wait_a()
end

------------------------------------------------------------
-- Main loop
------------------------------------------------------------

while true do
    local choice = main_menu()

    if not choice or choice == 15 then
        break

    elseif choice == 1 then
        system_information()

    elseif choice == 2 then
        sd_information()

    elseif choice == 3 then
        file_tools()

    elseif choice == 4 then
        hash_verify()

    elseif choice == 5 then
        title_tools()

    elseif choice == 6 then
        patch_tools()

    elseif choice == 7 then
        code_tools()

    elseif choice == 8 then
        key_tools()

    elseif choice == 9 then
        database_tools()

    elseif choice == 10 then
        cartridge_dump()

    elseif choice == 11 then
        led_tools()

    elseif choice == 12 then
        utilities()

    elseif choice == 13 then
        ten_step_lock()

    elseif choice == 14 then
        about()
    end
end
