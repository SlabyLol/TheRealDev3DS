--[[
    TheRealDev
    GodMode9 Lua Toolkit
    Version 0.1

    Security system:
    10 locks
    10 sequential button inputs per lock
    Wrong input = return to main menu
]]

local VERSION = "0.1"

------------------------------------------------------------
-- BUTTON DEFINITIONS
------------------------------------------------------------

local BUTTONS = {
    "A", "B", "X", "Y",
    "L", "R",
    "UP", "DOWN", "LEFT", "RIGHT",
    "START", "SELECT"
}

------------------------------------------------------------
-- SECURITY SEQUENCES
------------------------------------------------------------

local LOCKS = {
    {
        "A", "LEFT", "B", "UP", "R",
        "X", "DOWN", "L", "Y", "START"
    },

    {
        "X", "R", "UP", "A", "LEFT",
        "Y", "B", "DOWN", "L", "SELECT"
    },

    {
        "L", "A", "RIGHT", "Y", "DOWN",
        "R", "B", "UP", "X", "LEFT"
    },

    {
        "START", "B", "LEFT", "R", "UP",
        "A", "Y", "DOWN", "L", "X"
    },

    {
        "Y", "DOWN", "L", "A", "RIGHT",
        "X", "UP", "R", "B", "LEFT"
    },

    {
        "R", "X", "LEFT", "B", "START",
        "UP", "Y", "L", "DOWN", "A"
    },

    {
        "DOWN", "A", "X", "RIGHT", "L",
        "B", "UP", "SELECT", "R", "Y"
    },

    {
        "LEFT", "Y", "R", "DOWN", "B",
        "X", "START", "UP", "L", "A"
    },

    {
        "B", "UP", "START", "X", "RIGHT",
        "L", "A", "DOWN", "Y", "R"
    },

    {
        "SELECT", "L", "DOWN", "X", "A",
        "RIGHT", "R", "Y", "UP", "B"
    }
}

------------------------------------------------------------
-- UTILITY FUNCTIONS
------------------------------------------------------------

local function is_any_key_pressed()
    for _, key in ipairs(BUTTONS) do
        if ui.check_key(key) then
            return true
        end
    end

    return false
end

local function wait_for_release()
    while is_any_key_pressed() do
    end
end

local function get_pressed_key()
    for _, key in ipairs(BUTTONS) do
        if ui.check_key(key) then
            return key
        end
    end

    return nil
end

local function wait_for_key()
    while true do
        local key = get_pressed_key()

        if key ~= nil then
            return key
        end
    end
end

local function show_error(message)
    ui.show_text(
        "THE REALDEV\n\n" ..
        "ERROR\n\n" ..
        message
    )

    ui.echo(
        "Press A to return."
    )
end

------------------------------------------------------------
-- SECURITY LOCK
------------------------------------------------------------

local function run_lock(lock_number)
    local sequence = LOCKS[lock_number]

    if sequence == nil then
        return false
    end

    wait_for_release()

    for step = 1, #sequence do

        ui.show_text(
            "THE REALDEV\n" ..
            "SECURITY SYSTEM\n\n" ..
            "LOCK " .. lock_number .. " / 10\n\n" ..
            "ENTER SECURITY SEQUENCE\n\n" ..
            "Progress: " .. (step - 1) .. " / 10\n\n" ..
            "Input required..."
        )

        local key = wait_for_key()

        if key ~= sequence[step] then

            ui.show_text(
                "THE REALDEV\n" ..
                "SECURITY SYSTEM\n\n" ..
                "INCORRECT INPUT\n\n" ..
                "Lock " .. lock_number .. " failed.\n\n" ..
                "Returning to Main Menu..."
            )

            wait_for_release()

            -- Small confirmation pause.
            -- A simple key wait keeps the screen from disappearing instantly.
            ui.echo(
                "Security sequence failed.\n" ..
                "Press A to return to Main Menu."
            )

            return false
        end

        wait_for_release()
    end

    ui.show_text(
        "THE REALDEV\n" ..
        "SECURITY SYSTEM\n\n" ..
        "LOCK " .. lock_number .. " PASSED\n\n" ..
        "10 / 10 inputs correct."
    )

    wait_for_key()
    wait_for_release()

    return true
end

------------------------------------------------------------
-- FULL SECURITY SYSTEM
------------------------------------------------------------

local function security_unlock()
    for lock_number = 1, 10 do

        local success = run_lock(lock_number)

        if not success then
            return false
        end
    end

    ui.show_text(
        "THE REALDEV\n" ..
        "SECURITY SYSTEM\n\n" ..
        "ALL 10 LOCKS PASSED\n\n" ..
        "ACCESS GRANTED\n\n" ..
        "Advanced access unlocked."
    )

    ui.echo(
        "Press A to continue."
    )

    return true
end

------------------------------------------------------------
-- SYSTEM INFORMATION
------------------------------------------------------------

local function system_info()
    sys.refresh_info()

    local sd = fs.stat_fs("0:/")

    local text =
        "THE REALDEV\n" ..
        "SYSTEM INFORMATION\n\n" ..

        "GodMode9: " .. tostring(GM9VER) .. "\n" ..
        "Console: " .. tostring(CONSOLE_TYPE) .. "\n" ..
        "Devkit: " .. tostring(IS_DEVKIT) .. "\n\n" ..

        "Region: " .. tostring(sys.region) .. "\n" ..
        "Serial: " .. tostring(sys.serial) .. "\n\n" ..

        "SysNAND ID0:\n" ..
        tostring(sys.sys_id0) .. "\n\n" ..

        "EmuNAND ID0:\n" ..
        tostring(sys.emu_id0) .. "\n\n" ..

        "SD Total: " ..
        ui.format_bytes(sd.total) .. "\n" ..

        "SD Used: " ..
        ui.format_bytes(sd.used) .. "\n" ..

        "SD Free: " ..
        ui.format_bytes(sd.free)

    ui.show_text(text)

    ui.echo(
        "Press A to return."
    )
end

------------------------------------------------------------
-- SD STORAGE INFORMATION
------------------------------------------------------------

local function storage_info()
    local sd = fs.stat_fs("0:/")

    local percentage = 0

    if sd.total > 0 then
        percentage = math.floor((sd.used * 100) / sd.total)
    end

    ui.show_text(
        "THE REALDEV\n" ..
        "SD CARD STORAGE\n\n" ..

        "Total:\n" ..
        ui.format_bytes(sd.total) .. "\n\n" ..

        "Used:\n" ..
        ui.format_bytes(sd.used) .. "\n\n" ..

        "Free:\n" ..
        ui.format_bytes(sd.free) .. "\n\n" ..

        "Usage: " .. percentage .. "%"
    )

    ui.echo(
        "Press A to return."
    )
end

------------------------------------------------------------
-- FILE EXPLORER
------------------------------------------------------------

local function file_explorer()
    local path = fs.ask_select_file(
        "THE REALDEV - SELECT FILE",
        "0:/*",
        {
            include_dirs = true,
            explorer = true
        }
    )

    if path == nil then
        return
    end

    local ok, stat = pcall(fs.stat, path)

    if not ok then
        show_error("Could not read selected item.")
        return
    end

    local text =
        "THE REALDEV\n" ..
        "FILE INFORMATION\n\n" ..

        "Name:\n" ..
        tostring(stat.name) .. "\n\n" ..

        "Type:\n" ..
        tostring(stat.type) .. "\n\n" ..

        "Size:\n" ..
        ui.format_bytes(stat.size) .. "\n\n" ..

        "Read Only:\n" ..
        tostring(stat.read_only) .. "\n\n" ..

        "Path:\n" ..
        path

    ui.show_text(text)

    ui.echo(
        "Press A to return."
    )
end

------------------------------------------------------------
-- ABOUT
------------------------------------------------------------

local function about()
    ui.show_text(
        "THE REALDEV\n\n" ..

        "GodMode9 Lua Toolkit\n\n" ..

        "Version: " .. VERSION .. "\n\n" ..

        "Created for GodMode9 Lua.\n\n" ..

        "Features:\n" ..
        "- Security system\n" ..
        "- System information\n" ..
        "- Storage information\n" ..
        "- File tools\n" ..
        "- Advanced tools\n\n" ..

        "TheRealDev"
    )

    ui.echo(
        "Press A to return."
    )
end

------------------------------------------------------------
-- REBOOT
------------------------------------------------------------

local function reboot()
    if ui.ask(
        "Are you sure you want to reboot?"
    ) then
        sys.reboot()
    end
end

------------------------------------------------------------
-- POWER OFF
------------------------------------------------------------

local function power_off()
    if ui.ask(
        "Are you sure you want to power off?"
    ) then
        sys.power_off()
    end
end

------------------------------------------------------------
-- ADVANCED MENU
------------------------------------------------------------

local function advanced_menu()
    local unlocked = security_unlock()

    if not unlocked then
        return
    end

    local options = {
        "File Copy",
        "File Move",
        "File Delete",
        "Calculate SHA-256",
        "Verify File",
        "Create Directory",
        "Create DB Files",
        "Key Dump",
        "Back"
    }

    while true do

        local choice = ui.ask_selection(
            "THE REALDEV\n\nADVANCED TOOLS",
            options
        )

        if choice == nil or choice == #options then
            return
        end

        ------------------------------------------------
        -- FILE COPY
        ------------------------------------------------

        if choice == 1 then

            local src = fs.ask_select_file(
                "Select source",
                "0:/*",
                { explorer = true }
            )

            if src ~= nil then
                local dst = ui.ask_text(
                    "Destination path",
                    "0:/gm9/out/",
                    200
                )

                if dst ~= nil then
                    local ok, err = pcall(
                        fs.copy,
                        src,
                        dst
                    )

                    if not ok then
                        show_error(tostring(err))
                    else
                        ui.echo("Copy completed.")
                    end
                end
            end

        ------------------------------------------------
        -- FILE MOVE
        ------------------------------------------------

        elseif choice == 2 then

            local src = fs.ask_select_file(
                "Select source",
                "0:/*",
                { explorer = true }
            )

            if src ~= nil then
                local dst = ui.ask_text(
                    "Destination path",
                    "0:/gm9/out/",
                    200
                )

                if dst ~= nil then
                    local ok, err = pcall(
                        fs.move,
                        src,
                        dst
                    )

                    if not ok then
                        show_error(tostring(err))
                    else
                        ui.echo("Move completed.")
                    end
                end
            end

        ------------------------------------------------
        -- FILE DELETE
        ------------------------------------------------

        elseif choice == 3 then

            local path = fs.ask_select_file(
                "Select file to delete",
                "0:/*",
                { explorer = true }
            )

            if path ~= nil then

                if ui.ask(
                    "DELETE THIS ITEM?\n\n" .. path
                ) then

                    local ok, err = pcall(
                        fs.remove,
                        path
                    )

                    if not ok then
                        show_error(tostring(err))
                    else
                        ui.echo("Delete completed.")
                    end
                end
            end

        ------------------------------------------------
        -- SHA-256
        ------------------------------------------------

        elseif choice == 4 then

            local path = fs.ask_select_file(
                "Select file",
                "0:/*",
                { explorer = true }
            )

            if path ~= nil then

                local ok, hash = pcall(
                    fs.hash_file,
                    path,
                    0,
                    0
                )

                if ok then
                    ui.show_text(
                        "SHA-256\n\n" ..
                        util.bytes_to_hex(hash)
                    )

                    ui.echo(
                        "Press A to return."
                    )
                else
                    show_error(tostring(hash))
                end
            end

        ------------------------------------------------
        -- VERIFY
        ------------------------------------------------

        elseif choice == 5 then

            local path = fs.ask_select_file(
                "Select file to verify",
                "0:/*",
                { explorer = true }
            )

            if path ~= nil then

                local ok, result = pcall(
                    fs.verify,
                    path
                )

                if ok then
                    ui.echo(
                        "Verification result: " ..
                        tostring(result)
                    )
                else
                    show_error(tostring(result))
                end
            end

        ------------------------------------------------
        -- MKDIR
        ------------------------------------------------

        elseif choice == 6 then

            local path = ui.ask_text(
                "Directory path",
                "0:/gm9/out/NewFolder",
                200
            )

            if path ~= nil then

                local ok, err = pcall(
                    fs.mkdir,
                    path
                )

                if not ok then
                    show_error(tostring(err))
                else
                    ui.echo(
                        "Directory created."
                    )
                end
            end

        ------------------------------------------------
        -- CREATE DBS
        ------------------------------------------------

        elseif choice == 7 then

            local drive = ui.ask_selection(
                "Select destination",
                {
                    "SysNAND CTRNAND (1:)",
                    "EmuNAND CTRNAND (4:)",
                    "SysNAND SD (A:)",
                    "EmuNAND SD (B:)"
                }
            )

            if drive ~= nil then

                local drives = {
                    "1:",
                    "4:",
                    "A:",
                    "B:"
                }

                local ok, err = pcall(
                    fs.create_dbs,
                    drives[drive]
                )

                if not ok then
                    show_error(tostring(err))
                else
                    ui.echo(
                        "Database operation completed."
                    )
                end
            end

        ------------------------------------------------
        -- KEY DUMP
        ------------------------------------------------

        elseif choice == 8 then

            local key_type = ui.ask_selection(
                "Select key dump",
                {
                    "seeddb.bin",
                    "encTitleKeys.bin",
                    "decTitleKeys.bin"
                }
            )

            if key_type ~= nil then

                local files = {
                    "seeddb.bin",
                    "encTitleKeys.bin",
                    "decTitleKeys.bin"
                }

                local ok, err = pcall(
                    fs.key_dump,
                    files[key_type]
                )

                if not ok then
                    show_error(tostring(err))
                else
                    ui.echo(
                        "Key dump completed."
                    )
                end
            end
        end
    end
end

------------------------------------------------------------
-- MAIN MENU
------------------------------------------------------------

local function main_menu()

    local options = {
        "System Information",
        "SD Storage",
        "File Explorer",
        "Advanced Tools",
        "About",
        "Reboot",
        "Power Off",
        "Exit"
    }

    while true do

        local choice = ui.ask_selection(
            "THE REALDEV\n" ..
            "GodMode9 Lua Toolkit\n\n" ..
            "Version " .. VERSION,
            options
        )

        if choice == nil then
            return
        end

        if choice == 1 then
            system_info()

        elseif choice == 2 then
            storage_info()

        elseif choice == 3 then
            file_explorer()

        elseif choice == 4 then
            advanced_menu()

        elseif choice == 5 then
            about()

        elseif choice == 6 then
            reboot()

        elseif choice == 7 then
            power_off()

        elseif choice == 8 then
            return
        end
    end
end

------------------------------------------------------------
-- START
------------------------------------------------------------

ui.clear()

ui.show_text(
    "THE REALDEV\n\n" ..
    "GodMode9 Lua Toolkit\n\n" ..
    "Version " .. VERSION .. "\n\n" ..
    "Initializing..."
)

ui.echo(
    "Press A to start TheRealDev."
)

main_menu()
