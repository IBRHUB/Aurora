# AuroraSudo.exe

## About This Tool

**Note:** The tool has been renamed from MinSudo to AuroraSudo.exe to align with the Aurora project while maintaining the same core functionality.

**Original Source:** [https://github.com/M2Team/NanaRun](https://github.com/M2Team/NanaRun)

## Description

AuroraSudo (formerly known as MinSudo) is a lightweight POSIX-style Sudo implementation for Windows that allows users to run applications with elevated privileges from a standard console.

## System Requirements

- Operating System: Windows Vista RTM (Build 6000.16386) or later
- Supported Platforms: x86 (32-bit and 64-bit) and ARM (64-bit)

## Usage

**Format:** `AuroraSudo [Options] Command`

### Available Options:

- `--NoLogo, -NoL`: Suppress copyright message
- `--Verbose, -V`: Show detailed information
- `--WorkDir=[Path], -WD=[Path]`: Set working directory
- `--System, -S`: Run as System instead of Administrator
- `--TrustedInstaller, -TI`: Run as TrustedInstaller instead of Administrator
- `--Privileged, -P`: Enable all privileges
- `--Version, -Ver`: Show version information
- `/?, -H, --Help`: Show help content

### Notes:

- All command options are case-insensitive
- AuroraSudo will execute "cmd.exe" if you don't specify another command
- You can use the "/" or "--" override "-" and use the "=" override ":" in the command line parameters

### Example:

To run "whoami /all" with elevated privileges in a non-elevated console, without showing version information:
