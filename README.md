<p align="center">
<a href="https://ibrpride.com/" target="_blank"><img src="./Docs/Assets/AuroraBenner.png" alt="Aurora" width="800"></a>
<h3 align="center">Lighting Up Your PC's Performance</h3>
<br>

</p>

## 🤔 What is Aurora?

**Aurora** is an open-source project designed to enhance your Windows experience by applying privacy, usability, and performance optimizations.

## Features

- **Privacy Enhancements:** Safeguard your privacy by disabling unnecessary tracking. This process eliminates most telemetry embedded in Windows and enforces various group policies to significantly reduce data collection

- **Performance Boost:** Aurora achieves harmony between optimal performance and seamless compatibility. It introduces carefully crafted adjustments to enhance Windows' speed and responsiveness while preserving critical functionality. Unlike others, Aurora avoids superficial tweaks or negligible improvements, ensuring greater stability and reliability

- **User-Friendly:** With simple and intuitive usage for all users, Aurora operates through a single PowerShell command. Just input the corresponding numbers, and it will execute the tasks automatically, making it accessible and efficient for everyone.

## Expected Improvements :

- Enhanced gaming performance and reduced latency
- Faster system and program loading times
- Reduced system resource usage
- Optimized AMD/NVIDIA GPU performance
- Improved network settings and reduced lag
- Disabled unnecessary services and processes
- Enhanced overall desktop experience

## 💡 How to Use Aurora

Aurora requires administrative privileges to apply system-wide tweaks. Follow these steps to run it:

1. **Start Menu Method:**
   - Right-click on the Start Menu.
   - Choose "Windows PowerShell (Admin)" (Windows 10) or "Terminal (Admin)" (Windows 11).

2. **Search and Launch:**
   - Press the **Windows key**, type "PowerShell" or "Terminal."
   - Press `Ctrl + Shift + Enter` or right-click and choose "Run as administrator."

---

## ⚠️ Important Notes
Before using Aurora:
-  **Create a System Restore Point** to ensure you can undo any changes if needed.
-  **Back Up Your Data** for additional safety.

---

## Launch Command

Run the following command in PowerShell (Admin):

```powershell
irm "https://ibrpride.com/Aurora" | iex
```
Run the following command in Cmd (Admin):

```cmd
powershell -Command "irm 'https://ibrpride.com/Aurora' | iex"
```

If you encounter any errors or the above command doesn't work, try this alternative command:


```powershell
powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest "https://github.com/IBRHUB/Aurora/releases/download/0.6/Aurora.cmd" -OutFile "$env:temp\Aurora.cmd"; Start-process $env:temp\Aurora.cmd
```
<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/0/0d/Flag_of_Saudi_Arabia.svg" alt="Saudi Flag" width="20" height="20">
  &nbsp;<a href="https://github.com/IBRHUB/Aurora/blob/main/README.ar.md">Aurora in Arabic</a>
  &nbsp;&bull;&nbsp;
  <a href="https://github.com/IBRHUB/Aurora/blob/main/Troubleshooting">Troubleshooting</a>
  &nbsp;&bull;&nbsp;
  <a href="https://github.com/IBRHUB/Aurora/blob/main/LICENSE">LICENSE</a>
</p>


