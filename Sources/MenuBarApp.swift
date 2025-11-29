import Cocoa
import Foundation

// MARK: - Menu Bar Application
/// Fn key toggle application running in menu bar
class MenuBarApp: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!
    private let fnStateManager: FnStateManager
    private let fnKeyListener: FnKeyListener
    
    // Keep menu items as properties
    private var fnStatusMenuItem: NSMenuItem!
    private var launchAtLoginMenuItem: NSMenuItem!
    
    // Timer for periodic updates
    private var updateTimer: Timer?
    
    override init() {
        fnStateManager = FnStateManager()
        fnKeyListener = FnKeyListener()
        super.init()
        
        // Toggle state and update menu when Fn key is pressed
        fnKeyListener.onFnKeyPressed = { [weak self] in
            self?.fnStateManager.toggleFnState()
            self?.updateMenuIcon()
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set as menu bar application
        NSApp.setActivationPolicy(.accessory)
        
        setupMenuBar()
        
        // Check permission first
        if !FnKeyListener.hasInputMonitoringPermission() {
            showPermissionRequestAlert()
        } else {
            startFnListener()
        }
        
        updateMenuIcon()
        
        // Start periodic update timer
        startPeriodicUpdates()
        
        // Refresh Launch Agent if enabled (to ensure path is correct)
        if isLaunchAtLoginEnabled() {
            createLaunchAgent()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        fnKeyListener.stopListening()
        updateTimer?.invalidate()
    }
    
    // MARK: - Periodic Updates
    private func startPeriodicUpdates() {
        // Update every 1 second (less frequent)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMenuIconOnly()
        }
    }
    
    private func updateMenuIconOnly() {
        // Refresh state only for periodic control
        fnStateManager.refreshState()
        
        updateMenuIcon()
    }
    
    // MARK: - Menu Bar Setup
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        // Initial icon
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Fn Key Toggle")
        }
        statusItem.button?.toolTip = "Fn Key Toggle"
        
        menu = NSMenu()
        menu.delegate = self
        
        fnStatusMenuItem = NSMenuItem()
        fnStatusMenuItem.title = getFnStatusText()
        fnStatusMenuItem.isEnabled = false
        menu.addItem(fnStatusMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let toggleItem = NSMenuItem(title: Localizable.Menu.toggleFnState, action: #selector(toggleFnState), keyEquivalent: "t")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        let clearActionItem = NSMenuItem(title: Localizable.Menu.clearFnAction, action: #selector(clearFnAction), keyEquivalent: "")
        clearActionItem.target = self
        clearActionItem.toolTip = Localizable.Menu.clearFnActionTooltip
        menu.addItem(clearActionItem)
        
        menu.addItem(NSMenuItem.separator())
        
        launchAtLoginMenuItem = NSMenuItem(title: Localizable.Menu.launchAtLogin, action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginMenuItem.target = self
        launchAtLoginMenuItem.state = isLaunchAtLoginEnabled() ? .on : .off
        menu.addItem(launchAtLoginMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Language submenu
        let languageMenu = NSMenu()
        
        let turkishItem = NSMenuItem(title: Language.turkish.displayName, action: #selector(changeLanguage(_:)), keyEquivalent: "")
        turkishItem.target = self
        turkishItem.representedObject = Language.turkish
        turkishItem.state = Localizable.currentLanguage == .turkish ? .on : .off
        languageMenu.addItem(turkishItem)
        
        let englishItem = NSMenuItem(title: Language.english.displayName, action: #selector(changeLanguage(_:)), keyEquivalent: "")
        englishItem.target = self
        englishItem.representedObject = Language.english
        englishItem.state = Localizable.currentLanguage == .english ? .on : .off
        languageMenu.addItem(englishItem)
        
        let languageMenuItem = NSMenuItem(title: Localizable.Menu.language, action: nil, keyEquivalent: "")
        languageMenuItem.submenu = languageMenu
        menu.addItem(languageMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let aboutItem = NSMenuItem(title: Localizable.Menu.about, action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        let quitItem = NSMenuItem(title: Localizable.Menu.quit, action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    // MARK: - Menu Actions
    @objc private func toggleFnState() {
        fnStateManager.toggleFnState()
        updateMenuIcon()
    }
    
    @objc private func clearFnAction() {
        fnStateManager.clearFnKeyAction()
        
        let alert = NSAlert()
        alert.messageText = Localizable.Alert.fnActionClearedTitle
        alert.informativeText = Localizable.Alert.fnActionClearedMessage
        alert.addButton(withTitle: Localizable.Alert.ok)
        alert.runModal()
    }
    
    @objc private func changeLanguage(_ sender: NSMenuItem) {
        guard let selectedLanguage = sender.representedObject as? Language else { return }
        
        Localizable.currentLanguage = selectedLanguage
        
        // Rebuild menu to refresh all text
        setupMenuBar()
        updateMenuIcon()
    }
    
    @objc private func toggleLaunchAtLogin() {
        let currentState = isLaunchAtLoginEnabled()
        setLaunchAtLogin(enabled: !currentState)
        launchAtLoginMenuItem.state = isLaunchAtLoginEnabled() ? .on : .off
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = Localizable.Alert.aboutTitle
        alert.informativeText = Localizable.Alert.aboutMessage
        alert.addButton(withTitle: Localizable.Alert.ok)
        alert.runModal()
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    // MARK: - UI Updates
    private func updateMenuIcon() {
        let isEnabled = fnStateManager.getCurrentState()
        // fn = Function Keys (F1, F2...) - using 'fn' symbol if available, fallback to 'globe' if needed
        // sun.max = Media Keys (Brightness, Volume...)
        let symbolName = isEnabled ? "fn" : "sun.max"
        
        if let button = statusItem.button {
            // Try to load 'fn', if not available use 'globe'
            let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: getFnStatusText()) 
                ?? NSImage(systemSymbolName: "globe", accessibilityDescription: getFnStatusText())
            
            button.image = image
            button.title = "" // Ensure no text is shown
        }
        
        statusItem.button?.toolTip = "Fn Key Toggle - \(getFnStatusText())"
        
        fnStatusMenuItem.title = getFnStatusText()
        launchAtLoginMenuItem.state = isLaunchAtLoginEnabled() ? .on : .off
    }
    
    private func getFnStatusText() -> String {
        let state = fnStateManager.getCurrentState()
        return state ? Localizable.Status.functionKeys : Localizable.Status.multimediaKeys
    }
    
    private func startFnListener() {
        do {
            try fnKeyListener.startListening()
        } catch {
            print("Failed to start listener: \(error)")
        }
    }
    
    private func showPermissionRequestAlert() {
        let alert = NSAlert()
        alert.messageText = Localizable.Alert.permissionTitle
        alert.informativeText = Localizable.Alert.permissionMessage
        alert.alertStyle = .informational
        alert.addButton(withTitle: Localizable.Alert.openSettings)
        alert.addButton(withTitle: Localizable.Menu.quit)
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            // Open System Settings to Input Monitoring
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
                NSWorkspace.shared.open(url)
            }
        }
        
        // Quit app regardless of choice since without permission it can't function
        NSApplication.shared.terminate(self)
    }
    
    // MARK: - Launch at Login Management
    private func isLaunchAtLoginEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "LaunchAtLogin")
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "LaunchAtLogin")
        
        if enabled {
            // Launch Agent plist oluştur
            createLaunchAgent()
        } else {
            // Launch Agent plist sil
            removeLaunchAgent()
        }
    }
    
    private func createLaunchAgent() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let launchAgentsDir = homeDir.appendingPathComponent("Library/LaunchAgents")
        let plistPath = launchAgentsDir.appendingPathComponent("com.github.ahmetbilall.fntoggle.plist")
        
        do {
            // Ensure LaunchAgents directory exists
            if !FileManager.default.fileExists(atPath: launchAgentsDir.path) {
                try FileManager.default.createDirectory(at: launchAgentsDir, withIntermediateDirectories: true)
            }
            
            // Clean up old/duplicate plists (e.g. with timestamps)
            let fileURLs = try FileManager.default.contentsOfDirectory(at: launchAgentsDir, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                if fileURL.lastPathComponent.hasPrefix("com.github.ahmetbilall.fntoggle") && fileURL.lastPathComponent != "com.github.ahmetbilall.fntoggle.plist" {
                    try? FileManager.default.removeItem(at: fileURL)
                    print("🧹 Removed old plist: \(fileURL.lastPathComponent)")
                }
            }
            
            // Get app path
            let appPath = Bundle.main.bundlePath
            
            let plistContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>com.github.ahmetbilall.fntoggle</string>
                <key>ProgramArguments</key>
                <array>
                    <string>/usr/bin/open</string>
                    <string>\(appPath)</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
                <key>ProcessType</key>
                <string>Interactive</string>
            </dict>
            </plist>
            """
            
            try plistContent.write(to: plistPath, atomically: true, encoding: .utf8)
            print("Launch Agent created at \(plistPath.path)")
        } catch {
            print("Failed to create Launch Agent: \(error)")
            let alert = NSAlert()
            alert.messageText = "Launch at Login Error"
            alert.informativeText = "Failed to enable launch at login: \(error.localizedDescription)"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    private func removeLaunchAgent() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let plistPath = homeDir.appendingPathComponent("Library/LaunchAgents/com.github.ahmetbilall.fntoggle.plist")
        try? FileManager.default.removeItem(at: plistPath)
    }
    
    // MARK: - NSMenuDelegate
    func menuWillOpen(_ menu: NSMenu) {
        fnStatusMenuItem.title = getFnStatusText()
        launchAtLoginMenuItem.state = isLaunchAtLoginEnabled() ? .on : .off
    }
}