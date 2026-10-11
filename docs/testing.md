# Testing and limitations

Run from the repository root with Windows PowerShell 5.1 and, if installed, PowerShell 7:

```powershell
powershell.exe -NoProfile -File .\tests\validate-config.ps1
powershell.exe -NoProfile -File .\tests\test-scripts.ps1
pwsh.exe -NoProfile -File .\tests\validate-config.ps1
pwsh.exe -NoProfile -File .\tests\test-scripts.ps1
```

Configuration validation parses all PowerShell files and asserts authenticated example defaults. Functional tests create disposable synthetic worlds in the OS temporary directory, fake Java process discovery and confirmation input, and test process/lock rejection, backup integrity, world data copying, restore refusal, WhatIf, retained rollback, corrupt snapshots, traversal rejection and invalid startup prerequisites. No actual Minecraft process is launched. Fixtures contain invented bytes, not a playable Minecraft world.

Manual acceptance, during a separately authorized maintenance window: run `start.ps1 -CheckOnly` against the intended runtime; start with the client closed; join locally; stop through the console; back up and restore to a separate test runtime; verify both players' inventory and dimensions; test the tunnel remotely. Never use the production world as an automated test fixture.

CI repeats the synthetic tests on Windows with both PowerShell versions. It does not prove live-server compatibility, tunnel reliability, authentication-mod security, Minecraft data semantics, or resilience to power loss/disk failure. Treat `.partial` backups as incomplete and retain rollback copies.

## Local validation record - 2026-10-11

- Syntax and safe example checks passed in Windows PowerShell 5.1 and PowerShell 7.
- All 17 synthetic functional assertions passed in each shell.
- Read-only `start.ps1 -CheckOnly` passed against the existing runtime, with the expected offline-mode warning. No server was started.
- Tracked-file review, private-identifier pattern scan, ignore-rule probes and relative documentation-link checks passed.
- Live gameplay, real-world restore, failure under power loss, and hosted GitHub CI were not run.

The local test runner required normal host permissions because the execution sandbox blocked Windows PowerShell registry reads and a temporary-directory rename. No execution policy was changed and no active server was stopped.
