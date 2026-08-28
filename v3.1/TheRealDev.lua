--[[
================================================================================
  TheRealDev.lua  –  GodMode9 Lua 5.4 Multi-Tool
  Version 3.1

  Place at:  0:/gm9/luascripts/TheRealDev.lua

  v3.1 changes:
  • English as default language (DE still available)
  • Expanded LED control (Power, WiFi, Camera, 3D, Notification)
  • File inject (write one file into another)
  • More utilities & clearer menus
  • Honest note: real FTP is IMPOSSIBLE in GodMode9 Lua
    (no network/socket stack exposed to scripts)
  • Transfer tips section instead of fake FTP
  • Cleaner i18n + more safety
================================================================================
]]

local NAME    = "TheRealDev"
local VERSION = "3.1"

------------------------------------------------------------
-- LANGUAGE (EN default, DE optional)
------------------------------------------------------------

local LANG = "EN"   -- "EN" or "DE"

local T = {
    EN = {
        press_a          = "Press A to continue.",
        error_title      = "ERROR",
        cancel           = "Cancelled.",
        back             = "Back",
        done             = "Done.",
        select_file      = "Select file",
        select_any       = "Select file/folder",
        select_dir       = "Select directory",
        path             = "Path:",
        dest             = "Destination:",
        size_bytes       = "Size in bytes:",
        confirm_copy     = "COPY?",
        confirm_move     = "MOVE?",
        confirm_delete   = "WARNING!\n\nReally DELETE?",
        confirm_install  = "INSTALL TITLE?",
        confirm_decrypt  = "DECRYPT IN PLACE?",
        confirm_encrypt  = "ENCRYPT IN PLACE?",
        confirm_reboot   = "REBOOT CONSOLE?",
        confirm_poweroff = "POWER OFF CONSOLE?",
        confirm_inject   = "INJECT SOURCE INTO TARGET?",
        main_title       = "THE REAL DEV v",
        about_title      = "=== TheRealDev ===",
        sysinfo          = "=== SYSTEM INFORMATION ===",
        storage          = "=== SD STORAGE ===",
        dirinfo          = "=== DIRECTORY INFO ===",
        fileinfo         = "=== FILE INFORMATION ===",
        hardware         = "=== HARDWARE INFO ===",
        search_results   = "=== SEARCH RESULTS ===",
        nothing_found    = "Nothing found.",
        exists           = "EXISTS",
        not_exists       = "DOES NOT EXIST",
        is_dir           = "This item is a DIRECTORY.",
        is_file          = "This item is a FILE.",
        unknown_item     = "Could not identify the item.",
        copy_done        = "Copy completed.",
        move_done        = "Move completed.",
        delete_done      = "Delete completed.",
        mkdir_done       = "Directory created.",
        dummy_done       = "Dummy file created.",
        truncate_done    = "Truncate completed.",
        fill_done        = "File filled.",
        inject_done      = "Inject completed.",
        hash_saved       = "Hash saved as .sha",
        verify_ok        = "VERIFICATION PASSED",
        verify_fail      = "VERIFICATION FAILED\nor file is not verifiable.",
        sha_ok           = "SHA-256 CHECK PASSED",
        sha_fail         = "SHA-256 CHECK FAILED",
        sha_missing      = "Could not read the .sha file.",
        cia_done         = "CIA build completed.\n\nOutput:\n0:/gm9/out",
        install_done     = "Installation completed.",
        decrypt_done     = "Decryption completed.",
        encrypt_done     = "Encryption completed.",
        patch_done       = "Patch applied.",
        code_extract     = "Code extraction completed.",
        code_compress    = "Code compression completed.",
        key_done         = "Key dump created in\n0:/gm9/out",
        db_done          = "Database operation completed.",
        cart_done        = "Cartridge dump completed.",
        mount_done       = "Mounted:",
        unmount_done     = "Image unmounted.",
        no_image         = "No image is mounted.",
        led_done         = "LED state changed.",
        out_ensured      = "0:/gm9/out is ready.",
        cmac_done        = "CMACs fixed.",
        gameinfo_fail    = "Could not load game info.",
        lang_switched    = "Language switched.",
        ftp_impossible   = "FTP NOT AVAILABLE",
        transfer_tips    = "=== FILE TRANSFER TIPS ===",
    },
    DE = {
        press_a          = "A drücken zum Fortfahren.",
        error_title      = "FEHLER",
        cancel           = "Abgebrochen.",
        back             = "Zurück",
        done             = "Fertig.",
        select_file      = "Datei wählen",
        select_any       = "Datei/Ordner wählen",
        select_dir       = "Ordner wählen",
        path             = "Pfad:",
        dest             = "Ziel:",
        size_bytes       = "Größe in Bytes:",
        confirm_copy     = "KOPIEREN?",
        confirm_move     = "VERSCHIEBEN?",
        confirm_delete   = "WARNUNG!\n\nWirklich LÖSCHEN?",
        confirm_install  = "TITEL INSTALLIEREN?",
        confirm_decrypt  = "IN-PLACE ENTSCHLÜSSELN?",
        confirm_encrypt  = "IN-PLACE VERSCHLÜSSELN?",
        confirm_reboot   = "KONSOLE NEUSTARTEN?",
        confirm_poweroff = "KONSOLE AUSSCHALTEN?",
        confirm_inject   = "QUELLE IN ZIEL INJIZIEREN?",
        main_title       = "THE REAL DEV v",
        about_title      = "=== TheRealDev ===",
        sysinfo          = "=== SYSTEM-INFORMATION ===",
        storage          = "=== SD-SPEICHER ===",
        dirinfo          = "=== ORDNER-INFO ===",
        fileinfo         = "=== DATEI-INFO ===",
        hardware         = "=== HARDWARE-INFO ===",
        search_results   = "=== SUCHERGEBNISSE ===",
        nothing_found    = "Nichts gefunden.",
        exists           = "EXISTIERT",
        not_exists       = "EXISTIERT NICHT",
        is_dir           = "Dies ist ein ORDNER.",
        is_file          = "Dies ist eine DATEI.",
        unknown_item     = "Konnte nicht identifiziert werden.",
        copy_done        = "Kopieren abgeschlossen.",
        move_done        = "Verschieben abgeschlossen.",
        delete_done      = "Löschen abgeschlossen.",
        mkdir_done       = "Ordner erstellt.",
        dummy_done       = "Dummy-Datei erstellt.",
        truncate_done    = "Truncate abgeschlossen.",
        fill_done        = "Datei gefüllt.",
        inject_done      = "Inject abgeschlossen.",
        hash_saved       = "Hash gespeichert als .sha",
        verify_ok        = "Verifikation ERFOLGREICH",
        verify_fail      = "Verifikation FEHLGESCHLAGEN\noder Datei nicht prüfbar.",
        sha_ok           = "SHA-256 Prüfung OK",
        sha_fail         = "SHA-256 Prüfung FEHLGESCHLAGEN",
        sha_missing      = "SHA-Datei konnte nicht gelesen werden.",
        cia_done         = "CIA-Bau abgeschlossen.\n\nAusgabe:\n0:/gm9/out",
        install_done     = "Installation abgeschlossen.",
        decrypt_done     = "Entschlüsselung abgeschlossen.",
        encrypt_done     = "Verschlüsselung abgeschlossen.",
        patch_done       = "Patch angewendet.",
        code_extract     = "Code extrahiert.",
        code_compress    = "Code komprimiert.",
        key_done         = "Key-Dump erstellt in\n0:/gm9/out",
        db_done          = "Datenbank-Operation abgeschlossen.",
        cart_done        = "Cartridge-Dump abgeschlossen.",
        mount_done       = "Image gemountet:",
        unmount_done     = "Image unmounted.",
        no_image         = "Kein Image gemountet.",
        led_done         = "LED-Status geändert.",
        out_ensured      = "0:/gm9/out ist bereit.",
        cmac_done        = "CMACs repariert.",
        gameinfo_fail    = "Konnte Spiel-Info nicht laden.",
        lang_switched    = "Sprache gewechselt.",
        ftp_impossible   = "FTP NICHT VERFÜGBAR",
        transfer_tips    = "=== DATEI-TRANSFER TIPPS ===",
    }
}

local function t(key)
    local pack = T[LANG] or T.EN
    return pack[key] or key
end

------------------------------------------------------------
-- BASIC HELPERS
------------------------------------------------------------

local function pause(msg)
    ui.echo(msg or t("press_a"))
end

local function safe(fn)
    local ok, err = pcall(fn)
    if not ok then
        ui.echo(t("error_title") .. "\n\n" .. tostring(err) .. "\n\n" .. t("press_a"))
        return false
    end
    return true
end

local function confirm(msg)
    return ui.ask(msg)
end

local function choose_file(prompt, pattern)
    return fs.ask_select_file(
        prompt or t("select_file"),
        pattern or "0:/*",
        { include_dirs = false, explorer = true }
    )
end

local function choose_any(prompt)
    return fs.ask_select_file(
        prompt or t("select_any"),
        "0:/*",
        { include_dirs = true, explorer = true }
    )
end

local function choose_dir(prompt)
    return fs.ask_select_dir(
        prompt or t("select_dir"),
        "0:/",
        { explorer = true }
    )
end

local function input(prompt, initial, max)
    return ui.ask_text(prompt, initial or "", max or 200)
end

local function ensure_out()
    if not fs.exists("0:/gm9") then fs.mkdir("0:/gm9") end
    if not fs.exists("0:/gm9/out") then fs.mkdir("0:/gm9/out") end
end

------------------------------------------------------------
-- SYSTEM
------------------------------------------------------------

local function system_info()
    safe(function()
        local s = fs.stat_fs("0:/")
        local text =
            t("sysinfo") .. "\n\n" ..
            "GodMode9: " .. tostring(GM9VER) .. "\n" ..
            "Console: " .. tostring(CONSOLE_TYPE) .. "\n" ..
            "Devkit: " .. tostring(IS_DEVKIT) .. "\n" ..
            "Region: " .. tostring(sys.region) .. "\n" ..
            "Serial: " .. tostring(sys.serial) .. "\n" ..
            "SecureInfo: " .. tostring(sys.secureinfo_letter) .. "\n" ..
            "SysNAND ID0: " .. tostring(sys.sys_id0) .. "\n" ..
            "EmuNAND ID0: " .. tostring(sys.emu_id0) .. "\n" ..
            "EmuNAND Base: " .. tostring(sys.emu_base) .. "\n" ..
            "Gyro: " .. tostring(GYROMODEL) .. "\n" ..
            "HAX: " .. tostring(HAX) .. "\n" ..
            "NAND Size: " .. ui.format_bytes(NANDSIZE) .. "\n\n" ..
            "SD Total: " .. ui.format_bytes(s.total) .. "\n" ..
            "SD Used:  " .. ui.format_bytes(s.used) .. "\n" ..
            "SD Free:  " .. ui.format_bytes(s.free)
        ui.show_text(text)
        pause()
    end)
end

local function refresh_system()
    safe(function()
        sys.refresh_info()
        pause(t("done"))
    end)
end

local function system_checks()
    while true do
        local labels = LANG == "DE" and {
            "Embedded-Backup prüfen", "Raw-RTC prüfen",
            "System-Info aktualisieren", "System-Information", t("back")
        } or {
            "Embedded Backup Check", "Raw RTC Check",
            "Refresh System Info", "System Information", t("back")
        }
        local c = ui.ask_selection(LANG == "DE" and "SYSTEM-CHECKS" or "SYSTEM CHECKS", labels)
        if not c or c == 5 then return end
        if c == 1 then
            safe(function()
                local r = sys.check_embedded_backup()
                if r == true then
                    pause(LANG == "DE" and "Embedded-Backup OK." or "Embedded backup check passed.")
                elseif r == false then
                    pause(LANG == "DE" and "Vorgang abgelehnt." or "User declined.")
                else
                    pause(LANG == "DE" and "NCSD-Check fehlgeschlagen." or "NCSD check failed.")
                end
            end)
        elseif c == 2 then
            safe(function()
                local r = sys.check_raw_rtc()
                pause(r and (LANG == "DE" and "RTC OK." or "RTC check passed.")
                          or (LANG == "DE" and "RTC-Check abgelehnt." or "RTC check declined."))
            end)
        elseif c == 3 then refresh_system()
        elseif c == 4 then system_info()
        end
    end
end

------------------------------------------------------------
-- STORAGE & DIRECTORY
------------------------------------------------------------

local function storage_info()
    safe(function()
        local s = fs.stat_fs("0:/")
        ui.show_text(
            t("storage") .. "\n\n" ..
            "Total\n" .. ui.format_bytes(s.total) .. "\n\n" ..
            "Used\n"  .. ui.format_bytes(s.used)  .. "\n\n" ..
            "Free\n"  .. ui.format_bytes(s.free)
        )
        pause()
    end)
end

local function directory_info()
    local dir = choose_dir()
    if not dir then return end
    safe(function()
        local d = fs.dir_info(dir)
        ui.show_text(
            t("dirinfo") .. "\n\n" ..
            "Dir:\n" .. dir .. "\n\n" ..
            "Files: " .. tostring(d.files) .. "\n" ..
            "Dirs:  " .. tostring(d.dirs)  .. "\n" ..
            "Size:  " .. ui.format_bytes(d.size)
        )
        pause()
    end)
end

------------------------------------------------------------
-- FILE INFO / EXISTENCE / GAME INFO
------------------------------------------------------------

local function file_info()
    local path = choose_file()
    if not path then return end
    safe(function()
        local s = fs.stat(path)
        ui.show_text(
            t("fileinfo") .. "\n\n" ..
            "Name: " .. tostring(s.name) .. "\n" ..
            "Type: " .. tostring(s.type) .. "\n" ..
            "Size: " .. ui.format_bytes(s.size) .. "\n" ..
            "R/O:  " .. tostring(s.read_only) .. "\n\n" ..
            "Path:\n" .. path
        )
        pause()
    end)
end

local function file_exists()
    local path = input(t("path"), "0:/", 200)
    if not path then return end
    if fs.exists(path) then
        pause(t("exists") .. "\n\n" .. path)
    else
        pause(t("not_exists") .. "\n\n" .. path)
    end
end

local function file_type()
    local path = choose_any()
    if not path then return end
    if fs.is_dir(path) then
        pause(t("is_dir"))
    elseif fs.is_file(path) then
        pause(t("is_file"))
    else
        pause(t("unknown_item"))
    end
end

local function show_game_info()
    local path = choose_file(
        LANG == "DE" and "Spiel-Datei (CIA/3DS/NDS/GBA/...)" or "Select game file (CIA/3DS/NDS/GBA/...)",
        "0:/*"
    )
    if not path then return end
    safe(function()
        ui.show_game_info(path)
    end)
end

------------------------------------------------------------
-- SEARCH
------------------------------------------------------------

local function search_one()
    local pattern = input(LANG == "DE" and "Suchmuster:" or "Search pattern:", "0:/", 200)
    if not pattern then return end
    safe(function()
        local result = fs.find(pattern, { first = true })
        if result then
            pause((LANG == "DE" and "GEFUNDEN\n\n" or "FOUND\n\n") .. result)
        else
            pause(t("nothing_found"))
        end
    end)
end

local function search_all()
    local dir = choose_dir(LANG == "DE" and "Suchordner" or "Search directory")
    if not dir then return end
    local pattern = input(LANG == "DE" and "Dateiname-Muster:" or "Filename pattern:", "*", 100)
    if not pattern then return end
    safe(function()
        local results = fs.find_all(dir, pattern, { recursive = true })
        local text = t("search_results") .. "\n\n"
        if #results == 0 then
            text = text .. t("nothing_found")
        else
            for i, p in ipairs(results) do
                text = text .. tostring(i) .. ": " .. tostring(p) .. "\n"
            end
        end
        ui.show_text(text)
        pause()
    end)
end

local function free_filename()
    local pattern = input(LANG == "DE" and "Muster mit ?:" or "Pattern with ?:", "0:/file_??.bin", 200)
    if not pattern then return end
    safe(function()
        local result = fs.find_not(pattern)
        pause((LANG == "DE" and "FREIER NAME:\n\n" or "AVAILABLE:\n\n") .. tostring(result))
    end)
end

------------------------------------------------------------
-- FILE OPERATIONS
------------------------------------------------------------

local function copy_item()
    local src = choose_any(LANG == "DE" and "Quelle" or "Select source")
    if not src then return end
    local dst = input(t("dest"), "0:/", 200)
    if not dst then return end
    if not confirm(t("confirm_copy") .. "\n\n" .. src .. "\n\n→\n\n" .. dst) then return end
    safe(function()
        fs.copy(src, dst, { recursive = true })
        pause(t("copy_done"))
    end)
end

local function move_item()
    local src = choose_any(LANG == "DE" and "Quelle" or "Select source")
    if not src then return end
    local dst = input(t("dest"), "0:/", 200)
    if not dst then return end
    if not confirm(t("confirm_move") .. "\n\n" .. src .. "\n\n→\n\n" .. dst) then return end
    safe(function()
        fs.move(src, dst)
        pause(t("move_done"))
    end)
end

local function delete_item()
    local path = choose_any(LANG == "DE" and "Zum Löschen" or "Select item to delete")
    if not path then return end
    if not confirm(t("confirm_delete") .. "\n\n" .. path) then return end
    safe(function()
        fs.remove(path, { recursive = true })
        pause(t("delete_done"))
    end)
end

local function make_directory()
    local path = input(LANG == "DE" and "Ordner-Pfad:" or "Directory path:", "0:/NewFolder", 200)
    if not path then return end
    safe(function()
        fs.mkdir(path)
        pause(t("mkdir_done"))
    end)
end

local function make_dummy()
    local path = input(LANG == "DE" and "Dummy-Datei:" or "Dummy file:", "0:/dummy.bin", 200)
    if not path then return end
    local size = ui.ask_number(t("size_bytes"), 1024)
    if not size or size < 1 then return end
    safe(function()
        fs.make_dummy_file(path, size)
        pause(t("dummy_done"))
    end)
end

local function truncate_file()
    local path = choose_file()
    if not path then return end
    local size = ui.ask_number(LANG == "DE" and "Neue Größe:" or "New size in bytes:", 0)
    if not size then return end
    if not confirm((LANG == "DE" and "TRUNCATE?\n\n" or "TRUNCATE FILE?\n\n") .. path .. "\n\n→ " .. tostring(size)) then return end
    safe(function()
        fs.truncate(path, size)
        pause(t("truncate_done"))
    end)
end

local function fill_file()
    local path = choose_file()
    if not path then return end
    local byte = ui.ask_hex(LANG == "DE" and "Füll-Byte (hex):" or "Fill byte (hex):", 0x00, 2)
    if not byte then return end
    if not confirm((LANG == "DE" and "DATEI FÜLLEN?\n\n" or "FILL FILE?\n\n") .. path) then return end
    safe(function()
        fs.fill_file(path, 0, 0, string.char(byte))
        pause(t("fill_done"))
    end)
end

local function inject_file()
    local src = choose_file(LANG == "DE" and "Quelldatei (wird injiziert)" or "Source file (to inject)")
    if not src then return end
    local dst = choose_file(LANG == "DE" and "Zieldatei" or "Target file")
    if not dst then return end
    local offset = ui.ask_number(LANG == "DE" and "Offset in Ziel (Bytes):" or "Offset in target (bytes):", 0)
    if not offset or offset < 0 then return end
    if not confirm(t("confirm_inject") .. "\n\n" .. src .. "\n\n→\n\n" .. dst .. "\n@ " .. tostring(offset)) then return end
    safe(function()
        local data = fs.read_file(src, 0, 0)  -- full file
        fs.write_file(dst, offset, data, { overwrite = true })
        pause(t("inject_done"))
    end)
end

local function fix_cmacs()
    local path = choose_any(LANG == "DE" and "Pfad für CMAC-Fix" or "Path for CMAC fix")
    if not path then return end
    if not confirm((LANG == "DE" and "CMACs REPARIEREN?\n\n" or "FIX CMACs?\n\n") .. path) then return end
    safe(function()
        fs.fix_cmacs(path)
        pause(t("cmac_done"))
    end)
end

------------------------------------------------------------
-- READ / TEXT
------------------------------------------------------------

local function text_viewer()
    local path = choose_file(LANG == "DE" and "Textdatei" or "Select text file", "0:/*.txt")
    if path then
        safe(function() ui.show_file_text_viewer(path) end)
    end
end

local function read_file_hex()
    local path = choose_file()
    if not path then return end
    local size = ui.ask_number(LANG == "DE" and "Bytes lesen:" or "Bytes to read:", 256)
    if not size or size < 1 then return end
    safe(function()
        local data = fs.read_file(path, 0, size)
        ui.show_text("=== RAW DATA ===\n\nBytes: " .. tostring(#data) .. "\n\n" .. util.bytes_to_hex(data))
        pause()
    end)
end

------------------------------------------------------------
-- HASH & VERIFY
------------------------------------------------------------

local function hash_sha256(save)
    local path = choose_file()
    if not path then return end
    safe(function()
        local data = fs.hash_file(path, 0, 0)
        local hex  = util.bytes_to_hex(data)
        ui.show_text("=== SHA-256 ===\n\n" .. path .. "\n\n" .. hex)
        pause()
        if save and confirm(LANG == "DE" and "Als .sha speichern?" or "Save as .sha file?") then
            ensure_out()
            local sha_path = path .. ".sha"
            fs.write_file(sha_path, 0, hex .. "\n", { overwrite = true })
            pause(t("hash_saved") .. "\n\n" .. sha_path)
        end
    end)
end

local function hash_sha1()
    local path = choose_file()
    if not path then return end
    safe(function()
        local data = fs.hash_file(path, 0, 0, { sha1 = true })
        ui.show_text("=== SHA-1 ===\n\n" .. util.bytes_to_hex(data))
        pause()
    end)
end

local function hash_data()
    local text = input(LANG == "DE" and "Daten zum Hashen:" or "Data to hash:", "", 500)
    if not text then return end
    safe(function()
        local hash = fs.hash_data(text)
        ui.show_text("=== DATA SHA-256 ===\n\n" .. util.bytes_to_hex(hash))
        pause()
    end)
end

local function verify_file()
    local path = choose_file()
    if not path then return end
    safe(function()
        if fs.verify(path) then pause(t("verify_ok")) else pause(t("verify_fail")) end
    end)
end

local function verify_sha()
    local path = choose_file()
    if not path then return end
    safe(function()
        local r = fs.verify_with_sha_file(path)
        if r == true then pause(t("sha_ok"))
        elseif r == false then pause(t("sha_fail"))
        else pause(t("sha_missing")) end
    end)
end

------------------------------------------------------------
-- TITLE / CIA
------------------------------------------------------------

local function build_cia(legit)
    local path = choose_file(LANG == "DE" and "Titel wählen" or "Select title")
    if not path then return end
    local msg = legit
        and (LANG == "DE" and "LEGIT-CIA BAUEN?\n\n" or "BUILD LEGIT CIA?\n\n")
        or  (LANG == "DE" and "CIA BAUEN?\n\n" or "BUILD CIA?\n\n")
    if not confirm(msg .. path) then return end
    safe(function()
        if legit then title.build_cia(path, { legit = true }) else title.build_cia(path) end
        pause(t("cia_done"))
    end)
end

local function install_title(emunand)
    local path = choose_file(LANG == "DE" and "Titel zum Installieren" or "Select title to install")
    if not path then return end
    local msg = emunand
        and (LANG == "DE" and "IN EMUNAND INSTALLIEREN?\n\n" or "INSTALL TO EMUNAND?\n\n")
        or  t("confirm_install") .. "\n\n"
    if not confirm(msg .. path) then return end
    safe(function()
        if emunand then title.install(path, { emunand = true }) else title.install(path) end
        pause(t("install_done"))
    end)
end

local function crypt_title(encrypt)
    local path = choose_file()
    if not path then return end
    local msg = encrypt and t("confirm_encrypt") or t("confirm_decrypt")
    if not confirm(msg .. "\n\n" .. path) then return end
    safe(function()
        if encrypt then title.encrypt(path) pause(t("encrypt_done"))
        else title.decrypt(path) pause(t("decrypt_done")) end
    end)
end

------------------------------------------------------------
-- PATCHES
------------------------------------------------------------

local function apply_patch(kind)
    local ext = string.lower(kind)
    local patch_file = choose_file((LANG == "DE" and "Patch wählen (" or "Select ") .. kind .. (LANG == "DE" and ")" or " patch"), "0:/*." .. ext)
    if not patch_file then return end
    local source = choose_file(LANG == "DE" and "Quelldatei" or "Source file")
    if not source then return end
    local target = input(t("dest"), "0:/gm9/out/patched.bin", 200)
    if not target then return end
    if not confirm((LANG == "DE" and "PATCH ANWENDEN?\n\n" or "APPLY " .. kind .. " PATCH?\n\n") .. kind) then return end
    safe(function()
        ensure_out()
        if kind == "IPS" then title.apply_ips(patch_file, source, target)
        elseif kind == "BPS" then title.apply_bps(patch_file, source, target)
        else title.apply_bpm(patch_file, source, target) end
        pause(t("patch_done") .. "\n\n" .. target)
    end)
end

------------------------------------------------------------
-- CODE
------------------------------------------------------------

local function extract_code()
    local source = choose_file(LANG == "DE" and "Titel/Code-Quelle" or "Title/code source")
    if not source then return end
    local dest = input(t("dest"), "0:/gm9/out/code.bin", 200)
    if not dest then return end
    safe(function()
        ensure_out()
        title.extract_code(source, dest)
        pause(t("code_extract") .. "\n\n" .. dest)
    end)
end

local function compress_code()
    local source = choose_file(LANG == "DE" and "Extrahierter Code" or "Extracted code")
    if not source then return end
    local dest = input(t("dest"), "0:/gm9/out/code.compressed", 200)
    if not dest then return end
    safe(function()
        ensure_out()
        title.compress_code(source, dest)
        pause(t("code_compress") .. "\n\n" .. dest)
    end)
end

------------------------------------------------------------
-- KEYS / DATABASES / CART / IMAGE
------------------------------------------------------------

local function dump_key(name)
    if not confirm((LANG == "DE" and "ERSTELLEN: " or "CREATE ") .. name .. "?\n\n0:/gm9/out") then return end
    safe(function()
        ensure_out()
        fs.key_dump(name)
        pause(name .. "\n\n" .. t("key_done"))
    end)
end

local function create_database(drive)
    if not confirm((LANG == "DE" and "DATENBANKEN ERSTELLEN AUF\n\n" or "CREATE DATABASES ON\n\n") .. drive .. "?") then return end
    safe(function()
        fs.create_dbs(drive)
        pause(t("db_done"))
    end)
end

local function cart_dump()
    local size = ui.ask_number(
        LANG == "DE" and "Dump-Größe in Bytes (0 = auto falls unterstützt):" or "Dump size in bytes (0 = auto if supported):",
        0
    )
    if not size or size < 0 then
        pause(LANG == "DE" and "Ungültige Größe." or "Invalid size.")
        return
    end
    local output = input(t("dest"), "0:/gm9/out/cart.bin", 200)
    if not output then return end
    if not confirm((LANG == "DE" and "SPIELKARTE DUMPEN?\n\nGröße: " or "DUMP GAME CARD?\n\nSize: ") .. tostring(size)) then return end
    safe(function()
        ensure_out()
        fs.cart_dump(output, size)
        pause(t("cart_done") .. "\n\n" .. output)
    end)
end

local function mount_image()
    local path = choose_file(LANG == "DE" and "Image wählen" or "Select image")
    if not path then return end
    safe(function()
        fs.img_mount(path)
        pause(t("mount_done") .. "\n\n" .. path)
    end)
end

local function mounted_image()
    safe(function()
        local path = fs.get_img_mount()
        if path then
            pause((LANG == "DE" and "AKTUELLES IMAGE:\n\n" or "CURRENT IMAGE:\n\n") .. path)
        else
            pause(t("no_image"))
        end
    end)
end

local function unmount_image()
    if not confirm(LANG == "DE" and "IMAGE UNMOUNTEN?" or "UNMOUNT CURRENT IMAGE?") then return end
    safe(function()
        fs.img_umount()
        pause(t("unmount_done"))
    end)
end

------------------------------------------------------------
-- SD / EMUNAND / POWER
------------------------------------------------------------

local function switch_sd()
    if confirm(LANG == "DE" and "SD-Karte jetzt wechseln?" or "Switch the SD card now?") then
        safe(function()
            fs.sd_switch(LANG == "DE" and "Bitte SD-Karte wechseln." or "Please switch the SD card now.")
        end)
    end
end

local function next_emunand()
    if confirm(LANG == "DE" and "Zum nächsten EmuNAND wechseln?" or "Switch to next EmuNAND?") then
        safe(function() sys.next_emu() end)
    end
end

------------------------------------------------------------
-- LED (expanded)
------------------------------------------------------------

local function led_tools()
    while true do
        local labels = LANG == "DE" and {
            "Power-LED …", "WiFi-LED an/aus", "Kamera-LED an/aus",
            "3D-LED an/aus", "Notification-LED an/aus", t("back")
        } or {
            "Power LED …", "WiFi LED on/off", "Camera LED on/off",
            "3D LED on/off", "Notification LED on/off", t("back")
        }
        local c = ui.ask_selection(LANG == "DE" and "LED-TOOLS" or "LED TOOLS", labels)
        if not c or c == 6 then return end

        if c == 1 then
            local p_labels = LANG == "DE" and {
                "Normal", "Fade Blau", "Sleep", "Aus", "Rot", "Blau", "Blink Rot", t("back")
            } or {
                "Normal", "Fade Blue", "Sleep", "Off", "Red", "Blue", "Blink Red", t("back")
            }
            local p = ui.ask_selection("POWER LED", p_labels)
            if p and p < 8 then
                local states = { 0, 1, 2, 3, 4, 5, 6 }
                safe(function()
                    i2c.write(i2c.dev.MCU, i2c.mcu.reg.POWER_LED_STATE, { states[p] })
                    pause(t("led_done"))
                end)
            end
        elseif c == 2 then
            local on = confirm(LANG == "DE" and "WiFi-LED einschalten?" or "Turn WiFi LED ON?")
            safe(function()
                i2c.write(i2c.dev.MCU, i2c.mcu.reg.WLAN_LED_STATE, { on and 1 or 0 })
                pause(t("led_done"))
            end)
        elseif c == 3 then
            local on = confirm(LANG == "DE" and "Kamera-LED einschalten?" or "Turn Camera LED ON?")
            safe(function()
                i2c.write(i2c.dev.MCU, i2c.mcu.reg.CAMERA_LED_STATE, { on and 1 or 0 })
                pause(t("led_done"))
            end)
        elseif c == 4 then
            local on = confirm(LANG == "DE" and "3D-LED einschalten?" or "Turn 3D LED ON?")
            safe(function()
                i2c.write(i2c.dev.MCU, i2c.mcu.reg.LED_3D_STATE, { on and 1 or 0 })
                pause(t("led_done"))
            end)
        elseif c == 5 then
            local on = confirm(LANG == "DE" and "Notification-LED einschalten?" or "Turn Notification LED ON?")
            safe(function()
                i2c.write(i2c.dev.MCU, i2c.mcu.reg.NOTIFICATION_LED_STATE, { on and 1 or 0 })
                pause(t("led_done"))
            end)
        end
    end
end

------------------------------------------------------------
-- HARDWARE
------------------------------------------------------------

local function hardware_info()
    safe(function()
        local power   = i2c.read(i2c.dev.MCU, i2c.mcu.reg.POWER_STATUS, 1)
        local battery = i2c.read(i2c.dev.MCU, i2c.mcu.reg.BATTERY_PERCENTAGE_INT, 1)
        local voltage = i2c.read(i2c.dev.MCU, i2c.mcu.reg.BATTERY_VOLTAGE, 1)
        local volume  = i2c.read(i2c.dev.MCU, i2c.mcu.reg.VOLUME_SLIDER_RAW, 1)

        local bat_pct = battery and string.byte(battery, 1) or "?"
        local vol_raw = volume  and string.byte(volume, 1)  or "?"
        local pwr     = power   and string.byte(power, 1)   or "?"
        local volt    = voltage and string.byte(voltage, 1) or "?"

        ui.show_text(
            t("hardware") .. "\n\n" ..
            "Power status: " .. tostring(pwr) .. "\n" ..
            "Battery %:    " .. tostring(bat_pct) .. "\n" ..
            "Voltage raw:  " .. tostring(volt) .. "\n" ..
            "Volume slider:" .. tostring(vol_raw) .. "\n\n" ..
            "Console: " .. tostring(CONSOLE_TYPE) .. "\n" ..
            "Gyro:    " .. tostring(GYROMODEL)
        )
        pause()
    end)
end

------------------------------------------------------------
-- TRANSFER TIPS (instead of impossible FTP)
------------------------------------------------------------

local function transfer_tips()
    local text
    if LANG == "DE" then
        text =
            t("transfer_tips") .. "\n\n" ..
            "ECHTES FTP in GodMode9-Lua\nist NICHT möglich.\n\n" ..
            "GodMode9 läuft auf ARM9 und\nhat keinen Netzwerk-/Socket-\nStack für Lua-Scripts.\n\n" ..
            "Bessere Alternativen:\n\n" ..
            "1. SD-Karte am PC\n" ..
            "   (am sichersten & schnellsten)\n\n" ..
            "2. Homebrew FTP-Server\n" ..
            "   (ftpd / 3ds-ftpd o.ä.)\n" ..
            "   im normalen 3DS-Homebrew\n" ..
            "   (nicht in GodMode9)\n\n" ..
            "3. FBI / Universal-Updater\n" ..
            "   für CIAs & Apps\n\n" ..
            "4. GodMode9 SD wechseln\n" ..
            "   (Utilities → Switch SD)"
    else
        text =
            t("transfer_tips") .. "\n\n" ..
            "REAL FTP inside GodMode9 Lua\nis NOT possible.\n\n" ..
            "GodMode9 runs on ARM9 and has\nno network/socket stack exposed\nto Lua scripts.\n\n" ..
            "Better alternatives:\n\n" ..
            "1. Take the SD card to a PC\n" ..
            "   (safest & fastest)\n\n" ..
            "2. Homebrew FTP server\n" ..
            "   (ftpd / 3ds-ftpd etc.)\n" ..
            "   in normal 3DS homebrew\n" ..
            "   (NOT inside GodMode9)\n\n" ..
            "3. FBI / Universal-Updater\n" ..
            "   for CIAs & apps\n\n" ..
            "4. GodMode9 Switch SD\n" ..
            "   (Utilities → Switch SD)"
    end
    ui.show_text(text)
    pause()
end

------------------------------------------------------------
-- UTILITIES
------------------------------------------------------------

local function ensure_output()
    safe(function()
        ensure_out()
        pause(t("out_ensured"))
    end)
end

local function custom_text()
    local text = input(LANG == "DE" and "Text anzeigen:" or "Show text:", "", 500)
    if text then
        ui.show_text(text)
        pause()
    end
end

local function qr_code()
    local data = input(LANG == "DE" and "QR-Daten:" or "QR data:", "", 200)
    if not data then return end
    local prompt = input(LANG == "DE" and "Anzeige-Text:" or "Display text:", "QR", 100) or "QR"
    safe(function()
        ui.show_qr(prompt, data)
    end)
end

local function toggle_lang()
    LANG = (LANG == "EN") and "DE" or "EN"
    pause(t("lang_switched") .. " → " .. LANG)
end

------------------------------------------------------------
-- 10-STEP LOCK
------------------------------------------------------------

local function lock_step(step, key)
    local held = false
    while true do
        if ui.check_key(key) then
            if not held then
                held = true
                ui.show_text("LOCK STEP " .. tostring(step) .. "/10\n\nHold: " .. key)
            end
        else
            if held then return true end
        end
        if ui.check_key("B") then return false end
    end
end

local function wait_lock()
    local sequence = { "A", "B", "X", "Y", "L", "R", "UP", "DOWN", "LEFT", "RIGHT" }
    ui.show_text(
        LANG == "DE" and "10-SCHRITT-LOCK\n\nHalte die angezeigte Taste,\ndann loslassen.\nB = Abbruch."
                      or "10-STEP LOCK\n\nHold the shown key,\nthen release.\nB = Cancel."
    )
    pause()
    for i, key in ipairs(sequence) do
        if not lock_step(i, key) then
            pause(LANG == "DE" and "Abgebrochen.\nZurück zum Menü." or "Cancelled.\nReturning to menu.")
            return
        end
    end
    pause(LANG == "DE" and "LOCK ERFOLGREICH!\nAlle 10 Schritte bestanden." or "LOCK SUCCESS!\nAll 10 steps passed.")
end

------------------------------------------------------------
-- MENUS
------------------------------------------------------------

local function file_menu()
    while true do
        local labels = LANG == "DE" and {
            "Kopieren", "Verschieben", "Löschen", "Ordner erstellen",
            "Dummy-Datei", "Truncate", "Datei füllen", "Datei injizieren",
            "CMACs reparieren", "Datei-Info", "Existiert?", "Typ prüfen",
            "Spiel-Info", "Suche (eine)", "Suche (alle)", "Freier Dateiname",
            t("back")
        } or {
            "Copy", "Move", "Delete", "Create Directory",
            "Dummy File", "Truncate", "Fill File", "Inject File",
            "Fix CMACs", "File Information", "Exists?", "Check Type",
            "Show Game Info", "Search (one)", "Search (all)", "Free Filename",
            t("back")
        }
        local c = ui.ask_selection(LANG == "DE" and "DATEI-MANAGER" or "FILE MANAGER", labels)
        if not c or c == 17 then return end
        local actions = {
            copy_item, move_item, delete_item, make_directory,
            make_dummy, truncate_file, fill_file, inject_file,
            fix_cmacs, file_info, file_exists, file_type,
            show_game_info, search_one, search_all, free_filename
        }
        if actions[c] then actions[c]() end
    end
end

local function hash_menu()
    while true do
        local labels = LANG == "DE" and {
            "SHA-256", "SHA-256 + speichern", "SHA-1", "Daten hashen",
            "Datei verifizieren", "Mit .sha prüfen", t("back")
        } or {
            "SHA-256", "SHA-256 + save", "SHA-1", "Hash Data",
            "Verify File", "Verify with .sha", t("back")
        }
        local c = ui.ask_selection("HASH & VERIFY", labels)
        if not c or c == 7 then return end
        if c == 1 then hash_sha256(false)
        elseif c == 2 then hash_sha256(true)
        elseif c == 3 then hash_sha1()
        elseif c == 4 then hash_data()
        elseif c == 5 then verify_file()
        elseif c == 6 then verify_sha()
        end
    end
end

local function title_menu()
    while true do
        local labels = LANG == "DE" and {
            "CIA bauen", "Legit-CIA bauen", "Titel installieren",
            "In EmuNAND installieren", "Entschlüsseln", "Verschlüsseln", t("back")
        } or {
            "Build CIA", "Build Legit CIA", "Install Title",
            "Install to EmuNAND", "Decrypt", "Encrypt", t("back")
        }
        local c = ui.ask_selection(LANG == "DE" and "TITLE / CIA" or "TITLE / CIA TOOLS", labels)
        if not c or c == 7 then return end
        if c == 1 then build_cia(false)
        elseif c == 2 then build_cia(true)
        elseif c == 3 then install_title(false)
        elseif c == 4 then install_title(true)
        elseif c == 5 then crypt_title(false)
        elseif c == 6 then crypt_title(true)
        end
    end
end

local function patch_menu()
    while true do
        local c = ui.ask_selection(LANG == "DE" and "PATCH-TOOLS" or "PATCH TOOLS", { "IPS", "BPS", "BPM", t("back") })
        if not c or c == 4 then return end
        if c == 1 then apply_patch("IPS")
        elseif c == 2 then apply_patch("BPS")
        elseif c == 3 then apply_patch("BPM")
        end
    end
end

local function code_menu()
    while true do
        local labels = LANG == "DE" and { "Code extrahieren", "Code komprimieren", t("back") }
                                  or { "Extract Code", "Compress Code", t("back") }
        local c = ui.ask_selection(LANG == "DE" and "CODE-TOOLS" or "CODE TOOLS", labels)
        if not c or c == 3 then return end
        if c == 1 then extract_code() elseif c == 2 then compress_code() end
    end
end

local function key_menu()
    while true do
        local labels = { "aeskeydb.bin", "seeddb.bin", "movable.sed", "otp.bin", "sector0x96.bin", t("back") }
        local c = ui.ask_selection(LANG == "DE" and "KEY-TOOLS" or "KEY TOOLS", labels)
        if not c or c == 6 then return end
        local names = { "aeskeydb.bin", "seeddb.bin", "movable.sed", "otp.bin", "sector0x96.bin" }
        if names[c] then dump_key(names[c]) end
    end
end

local function database_menu()
    while true do
        local c = ui.ask_selection(LANG == "DE" and "DATENBANKEN" or "DATABASE TOOLS",
            { "SysNAND (1:)", "EmuNAND (4:)", "SD (0:)", t("back") })
        if not c or c == 4 then return end
        local drives = { "1:/", "4:/", "0:/" }
        if drives[c] then create_database(drives[c]) end
    end
end

local function mount_menu()
    while true do
        local labels = LANG == "DE" and { "Image mounten", "Aktuelles Image", "Unmounten", t("back") }
                                  or { "Mount Image", "Current Image", "Unmount", t("back") }
        local c = ui.ask_selection(LANG == "DE" and "IMAGE-TOOLS" or "IMAGE TOOLS", labels)
        if not c or c == 4 then return end
        if c == 1 then mount_image()
        elseif c == 2 then mounted_image()
        elseif c == 3 then unmount_image()
        end
    end
end

local function utilities_menu()
    while true do
        local labels = LANG == "DE" and {
            "System-Checks", "Speicher-Info", "SD wechseln",
            "gm9/out sicherstellen", "Text-Viewer", "Eigener Text",
            "QR-Code", "Hardware-Info", "Nächstes EmuNAND",
            "Transfer-Tipps (kein FTP)", "Neustart", "Ausschalten",
            "Sprache DE/EN", t("back")
        } or {
            "System Checks", "Storage Info", "Switch SD",
            "Ensure gm9/out", "Text Viewer", "Custom Text",
            "QR Code", "Hardware Info", "Next EmuNAND",
            "Transfer Tips (no FTP)", "Reboot", "Power Off",
            "Language DE/EN", t("back")
        }
        local c = ui.ask_selection("UTILITIES", labels)
        if not c or c == 14 then return end
        if c == 1 then system_checks()
        elseif c == 2 then storage_info()
        elseif c == 3 then switch_sd()
        elseif c == 4 then ensure_output()
        elseif c == 5 then text_viewer()
        elseif c == 6 then custom_text()
        elseif c == 7 then qr_code()
        elseif c == 8 then hardware_info()
        elseif c == 9 then next_emunand()
        elseif c == 10 then transfer_tips()
        elseif c == 11 then
            if confirm(t("confirm_reboot")) then safe(function() sys.reboot() end) end
        elseif c == 12 then
            if confirm(t("confirm_poweroff")) then safe(function() sys.power_off() end) end
        elseif c == 13 then toggle_lang()
        end
    end
end

local function about()
    local text =
        t("about_title") .. "\n\n" ..
        "Version " .. VERSION .. "\n\n" ..
        (LANG == "DE" and
            "Großes GodMode9-Lua-Multi-Tool.\n\n" ..
            "Features:\n" ..
            "• Dateiverwaltung & Suche\n" ..
            "• Hashing & Verifikation\n" ..
            "• CIA / Title-Tools\n" ..
            "• Patches (IPS/BPS/BPM)\n" ..
            "• Code extract/compress\n" ..
            "• Key- & Database-Tools\n" ..
            "• Cartridge-Dump\n" ..
            "• Image-Mount\n" ..
            "• Erweiterte LED-Tools\n" ..
            "• Spiel-Info-Viewer\n" ..
            "• Inject / Fill / CMAC-Fix\n" ..
            "• Transfer-Tipps\n" ..
            "• 10-Step-Lock\n" ..
            "• DE/EN Umschaltung\n\n" ..
            "Kein echtes FTP möglich\n(GodMode9 hat keinen\nNetzwerk-Stack für Lua)."
        or
            "Large GodMode9 Lua multi-tool.\n\n" ..
            "Features:\n" ..
            "• File management & search\n" ..
            "• Hashing & verification\n" ..
            "• CIA / Title tools\n" ..
            "• Patches (IPS/BPS/BPM)\n" ..
            "• Code extract/compress\n" ..
            "• Key & database tools\n" ..
            "• Cartridge dump\n" ..
            "• Image mount\n" ..
            "• Expanded LED tools\n" ..
            "• Game info viewer\n" ..
            "• Inject / Fill / CMAC fix\n" ..
            "• Transfer tips\n" ..
            "• 10-step lock\n" ..
            "• DE/EN language switch\n\n" ..
            "Real FTP is impossible\n(GodMode9 has no network\nstack for Lua scripts).")
    ui.show_text(text)
    pause()
end

------------------------------------------------------------
-- MAIN
------------------------------------------------------------

while true do
    local labels = LANG == "DE" and {
        "System-Information",
        "Datei-Manager",
        "Hash & Verify",
        "Title / CIA Tools",
        "Patch-Tools",
        "Code-Tools",
        "Key-Tools",
        "Datenbank-Tools",
        "Cartridge-Dump",
        "Image-Tools",
        "LED-Tools",
        "Utilities",
        "Speicher-Info",
        "10-Step-Lock",
        "Über TheRealDev",
        "Beenden"
    } or {
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

    local c = ui.ask_selection(t("main_title") .. VERSION, labels)

    if not c or c == 16 then
        break
    elseif c == 1 then system_info()
    elseif c == 2 then file_menu()
    elseif c == 3 then hash_menu()
    elseif c == 4 then title_menu()
    elseif c == 5 then patch_menu()
    elseif c == 6 then code_menu()
    elseif c == 7 then key_menu()
    elseif c == 8 then database_menu()
    elseif c == 9 then cart_dump()
    elseif c == 10 then mount_menu()
    elseif c == 11 then led_tools()
    elseif c == 12 then utilities_menu()
    elseif c == 13 then storage_info()
    elseif c == 14 then wait_lock()
    elseif c == 15 then about()
    end
end
