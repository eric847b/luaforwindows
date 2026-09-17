# Building Lua for Windows

Lua for Windows is an old, self-contained Lua 5.1 distribution and Windows installer. The repository deliberately keeps the packaged binaries and libraries under `files/`; the installer definition is `LuaForWindows.iss`.

## Automated build

Every push and pull request that changes installer inputs runs `.github/workflows/build-installer.yml` on Windows. The workflow:

1. checks that the required installer inputs exist;
2. rejects insecure `http://` download endpoints in the installer definition;
3. installs Inno Setup 6;
4. compiles the installer; and
5. uploads the generated `LuaForWindows_v*.exe` as a workflow artifact.

Run it manually from the **Actions** tab with **Build installer → Run workflow**.

## Local build

1. Install [Inno Setup 6](https://jrsoftware.org/isinfo.php).
2. Clone this repository on Windows.
3. From PowerShell, run:

   ```powershell
   ./scripts/validate-installer.ps1
   & "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe" .\LuaForWindows.iss
   ```

The installer is written to the repository root. Its filename contains the version defined by `MyAppDisplayVer` in `LuaForWindows.iss`.

## Important compatibility notes

- The distribution targets Lua 5.1 and includes legacy 32-bit Windows components. Do not replace bundled DLLs or runtimes without testing every packaged native module.
- The Visual C++ redistributable is intentionally shipped as an installer input. Build and test the resulting installer in a clean Windows virtual machine before publishing a release.
- The validation script checks repository inputs and prevents accidental reintroduction of insecure HTTP URLs; it is not a substitute for signing or malware scanning release artifacts.
