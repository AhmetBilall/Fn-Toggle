import Cocoa
import Foundation

// MARK: - Fn Key State Manager
/// Manages Fn key state functionality
/// This class is responsible only for changing system settings
class FnStateManager {
    private var currentState: Bool = false
    
    /// Initializes manager and reads current fn state
    init() {
        getCurrentFnState()
    }
    
    /// Reads current fn state from system settings
    private func getCurrentFnState() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task.arguments = ["read", "-g", "com.apple.keyboard.fnState"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try runTask(task)
            
            let data: Data
            if #available(macOS 10.15.4, *) {
                data = try pipe.fileHandleForReading.readToEnd() ?? Data()
            } else {
                data = pipe.fileHandleForReading.readDataToEndOfFile()
            }
            
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                currentState = (output == "1")
            }
        } catch {
            print("⚠️ Error reading Fn state: \(error)")
        }
    }
    
    /// Toggles Fn key state
    func toggleFnState() {
        getCurrentFnState()
        let oldState = currentState
        
        currentState.toggle()
        setFnState(enabled: currentState)
        
        getCurrentFnState()
        
        if oldState != currentState {
            print("✅ Fn state changed: \(currentState ? "🎹 Function" : "⌨️ Multimedia")")
            playSystemSound()
        }
    }
    
    /// Sets fn state in system settings
    private func setFnState(enabled: Bool) {
        // Change Fn state
        let task1 = Process()
        task1.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task1.arguments = ["write", "-g", "com.apple.keyboard.fnState", "-bool", enabled ? "true" : "false"]
        
        do {
            try runTask(task1)
            
            // Activate settings
            let activateSettingsPath = "/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings"
            
            if FileManager.default.fileExists(atPath: activateSettingsPath) {
                let task2 = Process()
                task2.executableURL = URL(fileURLWithPath: activateSettingsPath)
                task2.arguments = ["-u"]
                try runTask(task2)
            } else {
                print("⚠️ activateSettings tool not found at \(activateSettingsPath)")
                showErrorAlert(message: "activateSettings tool not found. Changes may not take effect immediately.")
            }
        } catch {
             print("❌ Error setting Fn state: \(error)")
             showErrorAlert(message: "Failed to set Fn state: \(error.localizedDescription)")
        }
    }
    
    private func showErrorAlert(message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Fn Toggle Error"
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    /// Helper to run process safely
    private func runTask(_ task: Process) throws {
        if #available(macOS 10.13, *) {
            try task.run()
        } else {
            task.launch()
        }
        task.waitUntilExit()
    }
    
    /// Plays system sound effect
    private func playSystemSound() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/afplay")
        task.arguments = ["/System/Library/Sounds/Pop.aiff"]
        try? runTask(task)
    }
    
    /// Returns current fn state (from cache)
    func getCurrentState() -> Bool {
        return currentState
    }
    
    /// Re-reads system state
    func refreshState() {
        getCurrentFnState()
    }
    
    /// Clears system Fn key action (sets to "Do Nothing")
    func clearFnKeyAction() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task.arguments = ["write", "com.apple.HIToolbox", "AppleFnUsageType", "-int", "0"]
        
        do {
            try runTask(task)
            print("✅ System Fn action cleared (AppleFnUsageType = 0)")
            
            // Also try to restart HID services or notify system if possible
            // Usually 'defaults write' is enough for this specific setting to take effect on next press or app restart
            // But sometimes a logout/login is needed for full effect if not using private frameworks
        } catch {
            print("❌ Error clearing Fn action: \(error)")
            showErrorAlert(message: "Failed to clear Fn action: \(error.localizedDescription)")
        }
    }
}
