# TheRealDev3DS

**TheRealDev** – a powerful multi-tool script for **GodMode9** (Lua 5.4).

## Version 3.1 (recommended)

### What's new / better

| Area | Improvement |
|------|-------------|
| **Language** | **English default** + full German (toggle in Utilities) |
| **LED Tools** | Power + **WiFi / Camera / 3D / Notification** LEDs |
| **File Manager** | New: **Inject File**, Fill, Fix CMACs, Game Info viewer |
| **Hash** | SHA-256 optionally saved as `.sha` |
| **Transfer** | Honest **Transfer Tips** (real FTP is impossible) |
| **Structure** | Cleaner modular code, better error handling |
| **Safety** | Clearer confirmations |

### Important: FTP is not possible

GodMode9 runs on the ARM9 processor and **does not expose any network / socket / FTP API** to Lua scripts.  
There is no way to implement real FTP from inside a GodMode9 Lua script.

**Better alternatives** (also shown in the script under *Utilities → Transfer Tips*):

1. Take the SD card to a PC (fastest & safest)
2. Use a homebrew FTP server (**ftpd**, 3ds-ftpd, etc.) in normal 3DS homebrew mode
3. FBI / Universal-Updater for CIAs
4. GodMode9 "Switch SD" feature

## Installation

1. Use a recent **GodMode9** with Lua support.
2. Copy the script to:
   ```
   0:/gm9/luascripts/TheRealDev.lua
   ```
3. In GodMode9: **HOME** → **Lua scripts...** → **TheRealDev**  
   or select the file → **Execute Lua script**.

## Features overview

- System information (GM9 version, console type, region, serial, ID0, NAND size, SD space …)
- System checks (Embedded Backup, Raw RTC, Refresh)
- File Manager: Copy / Move / Delete / Mkdir / Dummy / Truncate / Fill / **Inject** / CMACs / Search / Game Info
- Hash & Verify: SHA-256, SHA-1, Hash data, Verify, Verify with `.sha`
- Title / CIA: Build CIA, Legit CIA, Install (SysNAND + EmuNAND), Decrypt / Encrypt
- Patches: IPS / BPS / BPM
- Code: Extract & Compress
- Keys: aeskeydb, seeddb, movable.sed, otp, sector0x96
- Databases on SysNAND / EmuNAND / SD
- Cartridge dump
- Image mount / unmount
- Expanded LED control
- Hardware info (battery, voltage, volume slider via I2C)
- Utilities: Switch SD, Next EmuNAND, Reboot / Power Off, QR, Text viewer, Transfer Tips, Language switch
- 10-Step Lock (fun / demo)

## Language

Default is **English**.  
Switch anytime: **Utilities → Language DE/EN**.  
Or set `LANG = "DE"` at the top of the script.

## Folder structure in this repo

```
v0.1/ … v2.0/   – older versions
v3.0/           – German-default version
v3.1/           – English-default + more features (recommended)
```

## Safety notes

- Write access to NAND and critical areas still requires the normal GodMode9 unlock sequences.
- Always confirm risky actions (Install, Decrypt, Delete, Cart Dump, Inject …).
- Keep NAND backups.
- No network functionality exists inside GodMode9 Lua.

## Credits

- GodMode9 by **d0k3** & contributors
- Lua API documentation (`lua-doc.md`)
- TheRealDev by **SlabyLol** – continued development to v3.1

## License

Free to use. Please credit the original author and this version when sharing.
