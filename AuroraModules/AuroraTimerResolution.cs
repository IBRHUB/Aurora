/*
 * Aurora Timer Resolution Service
 * 
 * This service optimizes Windows system timer resolution for better performance.
 * It monitors specific processes and automatically adjusts the timer resolution
 * when those processes start/stop.
 * 
 * Features:
 * - Configurable process monitoring via .ini file
 * - Automatic timer resolution adjustment (0.6ms target)
 * - System service that runs with LocalSystem privileges
 * - Event logging for diagnostics
 * 
 * Copyright © Aurora Project
 */

using System;
using System.Runtime.InteropServices;
using System.ServiceProcess;
using System.ComponentModel;
using System.Configuration.Install;
using System.Collections.Generic;
using System.Reflection;
using System.IO;
using System.Management;
using System.Threading;
using System.Diagnostics;

[assembly: AssemblyVersion("2.1")]
[assembly: AssemblyProduct("Aurora Timer Resolution Service")]
[assembly: AssemblyDescription("Aurora Timer Resolution Service - Optimizes system timer resolution")]
[assembly: AssemblyCopyright("Copyright © Aurora Project")]

namespace WindowsService {
    // Windows service that controls system timer resolution
    class WindowsService : ServiceBase {
        private ManagementEventWatcher startWatch;
        private List<String> ProcessesNames = null;
        private uint DefaultResolution = 0;
        private uint MininumResolution = 0;
        private uint MaximumResolution = 0;
        private long processCounter = 0;
        private OnProcessStart ProcessStartDelegate = null;
        private const UInt32 SYNCHRONIZE = 0x00100000;
        private const uint TARGET_RESOLUTION = 6000; // 0.6ms = 6000 (100ns units)

        public WindowsService() {
            this.ServiceName = "AuroraTimerService";
            this.EventLog.Log = "Application";
            this.CanStop = true;
            this.CanHandlePowerEvent = false;
            this.CanHandleSessionChangeEvent = false;
            this.CanPauseAndContinue = false;
            this.CanShutdown = false;
        }

        static void Main() {
            ServiceBase.Run(new WindowsService());
        }

        // Executed when service starts
        protected override void OnStart(string[] args) {
            base.OnStart(args);
            ReadProcessList();
            NtQueryTimerResolution(out this.MininumResolution, out this.MaximumResolution, out this.DefaultResolution);

            if(null != this.EventLog)
                try { 
                    this.EventLog.WriteEntry(String.Format("Minimum={0}; Maximum={1}; Default={2}; Processes='{3}'", 
                        this.MininumResolution, this.MaximumResolution, this.DefaultResolution, 
                        null != this.ProcessesNames ? String.Join("','", this.ProcessesNames) : "")); 
                }
                catch {}

            if(null == this.ProcessesNames) {
                SetMaximumResolution();
                return;
            }

            if(0 == this.ProcessesNames.Count) {
                return;
            }

            // Setup monitoring for new processes
            this.ProcessStartDelegate = new OnProcessStart(this.ProcessStarted);
            try {
                String query = String.Format("SELECT * FROM __InstanceCreationEvent WITHIN 0.5 WHERE (TargetInstance isa \"Win32_Process\") AND (TargetInstance.Name=\"{0}\")", 
                    String.Join("\" OR TargetInstance.Name=\"", this.ProcessesNames));
                this.startWatch = new ManagementEventWatcher(query);
                this.startWatch.EventArrived += this.startWatch_EventArrived;
                this.startWatch.Start();
            }
            catch(Exception ee) {
                if(null != this.EventLog)
                    try { this.EventLog.WriteEntry(ee.ToString(), EventLogEntryType.Error); }
                    catch {}
            }
        }

        protected override void OnStop() {
            if(null != this.startWatch) {
                this.startWatch.Stop();
            }
            base.OnStop();
        }

        // Handle new process start event
        void startWatch_EventArrived(object sender, EventArrivedEventArgs e) {
            try {
                ManagementBaseObject process = (ManagementBaseObject)e.NewEvent.Properties["TargetInstance"].Value;
                UInt32 processId = (UInt32)process.Properties["ProcessId"].Value;
                this.ProcessStartDelegate.BeginInvoke(processId, null, null);
            } 
            catch(Exception ee) {
                if(null != this.EventLog)
                    try { this.EventLog.WriteEntry(ee.ToString(), EventLogEntryType.Warning); }
                    catch {}
            }
        }

        // Core Windows system function calls
        [DllImport("kernel32.dll", SetLastError=true)]
        static extern Int32 WaitForSingleObject(IntPtr Handle, Int32 Milliseconds);

        [DllImport("kernel32.dll", SetLastError=true)]
        static extern IntPtr OpenProcess(UInt32 DesiredAccess, Int32 InheritHandle, UInt32 ProcessId);

        [DllImport("kernel32.dll", SetLastError=true)]
        static extern Int32 CloseHandle(IntPtr Handle);

        delegate void OnProcessStart(UInt32 processId);

        // Handle process start and adjust timer resolution
        void ProcessStarted(UInt32 processId) {
            SetMaximumResolution();
            IntPtr processHandle = IntPtr.Zero;
            try {
                processHandle = OpenProcess(SYNCHRONIZE, 0, processId);
                if(processHandle != IntPtr.Zero)
                    WaitForSingleObject(processHandle, -1);
            } 
            catch(Exception ee) {
                if(null != this.EventLog)
                    try { this.EventLog.WriteEntry(ee.ToString(), EventLogEntryType.Warning); }
                    catch {}
            }
            finally {
                if(processHandle != IntPtr.Zero)
                    CloseHandle(processHandle); 
            }
            SetDefaultResolution();
        }

        // Read process list from configuration file
        void ReadProcessList() {
            String iniFilePath = Assembly.GetExecutingAssembly().Location + ".ini";
            if(File.Exists(iniFilePath)) {
                this.ProcessesNames = new List<String>();
                String[] iniFileLines = File.ReadAllLines(iniFilePath);
                foreach(var line in iniFileLines) {
                    String[] names = line.Split(new char[] {',', ' ', ';'} , StringSplitOptions.RemoveEmptyEntries);
                    foreach(var name in names) {
                        String lwr_name = name.ToLower();
                        if(!lwr_name.EndsWith(".exe"))
                            lwr_name += ".exe";
                        if(!this.ProcessesNames.Contains(lwr_name))
                            this.ProcessesNames.Add(lwr_name);
                    }
                }
            }
        }

        // Windows system calls for timer resolution control
        [DllImport("ntdll.dll", SetLastError=true)]
        static extern int NtSetTimerResolution(uint DesiredResolution, bool SetResolution, out uint CurrentResolution);

        [DllImport("ntdll.dll", SetLastError=true)]
        static extern int NtQueryTimerResolution(out uint MinimumResolution, out uint MaximumResolution, out uint ActualResolution);

        // Set timer resolution to maximum
        void SetMaximumResolution() {
            long counter = Interlocked.Increment(ref this.processCounter);
            if(counter <= 1) {
                uint actual = 0;
                NtSetTimerResolution(TARGET_RESOLUTION, true, out actual);
                if(null != this.EventLog)
                    try { this.EventLog.WriteEntry(String.Format("Actual resolution = {0}", actual)); }
                    catch {}
            }
        }

        // Reset timer resolution to default
        void SetDefaultResolution() {
            long counter = Interlocked.Decrement(ref this.processCounter);
            if(counter < 1) {
                uint actual = 0;
                NtSetTimerResolution(TARGET_RESOLUTION, true, out actual);
                if(null != this.EventLog)
                    try { this.EventLog.WriteEntry(String.Format("Actual resolution = {0}", actual)); }
                    catch {}
            }
        }
    }

    // Service installer class
    [RunInstaller(true)]
    public class WindowsServiceInstaller : Installer {
        public WindowsServiceInstaller() {
            ServiceProcessInstaller serviceProcessInstaller = new ServiceProcessInstaller();
            ServiceInstaller serviceInstaller = new ServiceInstaller();

            serviceProcessInstaller.Account = ServiceAccount.LocalSystem;
            serviceProcessInstaller.Username = null;
            serviceProcessInstaller.Password = null;

            serviceInstaller.DisplayName = "Aurora Timer Resolution Service";
            serviceInstaller.Description = "Aurora Timer Resolution Service - Optimizes system timer resolution for better performance";
            serviceInstaller.StartType = ServiceStartMode.Automatic;
            serviceInstaller.ServiceName = "AuroraTimerService";

            this.Installers.Add(serviceProcessInstaller);
            this.Installers.Add(serviceInstaller);
        }
    }
}