# Java setup

Install the Windows x64 Temurin JDK 25 from [Adoptium](https://adoptium.net/temurin/releases/?version=25). Set `JAVA_HOME` to the JDK installation directory, without `\bin`, via Windows environment variable settings. Optionally add `%JAVA_HOME%\bin` to PATH. Reopen terminals after changes.

```powershell
Test-Path "$env:JAVA_HOME\bin\java.exe"
& "$env:JAVA_HOME\bin\java.exe" -version
```

The inspected host reported Temurin 25.0.4.1. The startup script checks the executable under `JAVA_HOME` directly and requires major version 25; PATH may point to a different Java. No user-specific installation path is committed.

[Fabric's Windows Java guide](https://docs.fabricmc.net/players/installing-java/windows) describes Java 25 installation for modern Minecraft. Recheck the game's Java requirement before upgrading beyond the documented Minecraft version. Start with default JVM ergonomics and `-Xms2G -Xmx4G`; avoid copying unrelated GC flag packs.

If PowerShell script execution is blocked, inspect `Get-ExecutionPolicy -List` and follow your machine's policy. For your own downloaded, reviewed files, `Unblock-File` may remove an Internet-origin mark. Do not bypass organizational policy or disable protections globally.
