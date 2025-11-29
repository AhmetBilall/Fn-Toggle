import Foundation
import IOKit.hid

// MARK: - Configuration
/// Configuration constants for HID system
struct HIDConfig {
    static let appleVendorPage: UInt32 = 0xFF00
    static let appleVendorPageAlt: UInt32 = 0x00FF
    static let fnKeyUsage: UInt32 = 0x0003
}

// MARK: - Fn Key Listener
/// Class that listens for Fn key presses
/// This class is only responsible for detecting key presses
class FnKeyListener {
    private let manager: IOHIDManager
    private var lastFnPressTime: CFTimeInterval = 0
    private let debounceInterval: CFTimeInterval = 0.3 // 300ms debounce
    
    /// Closure to be called when Fn key is pressed
    var onFnKeyPressed: (() -> Void)?
    
    /// Initializes listener and sets up HID manager
    init() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        setupHIDManager()
    }
    
    /// Sets up HID Manager and configures filter
    private func setupHIDManager() {
        // Apple keyboard filter
        let deviceMatching: CFDictionary = [
            kIOHIDDeviceUsagePageKey: 0x01,
            kIOHIDDeviceUsageKey: 0x06,
            kIOHIDManufacturerKey: "Apple Inc."
        ] as CFDictionary
        
        IOHIDManagerSetDeviceMatching(manager, deviceMatching)
        
        // Set up input callback
        let inputCallback: IOHIDValueCallback = { _, _, _, value in
            // No need to use context to access self,
            // will use direct static callback structure
            FnKeyListener.handleInput(value)
        }
        
        IOHIDManagerRegisterInputValueCallback(manager, inputCallback, nil)
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes.rawValue)
    }
    
    /// Handles HID input (static method for callback)
    private static var sharedInstance: FnKeyListener?
    
    private static func handleInput(_ value: IOHIDValue) {
        guard let instance = sharedInstance else { return }
        instance.processInput(value)
    }
    
    /// Processes input and detects fn key press
    private func processInput(_ value: IOHIDValue) {
        let element = IOHIDValueGetElement(value)
        let usagePage = IOHIDElementGetUsagePage(element)
        let usage = IOHIDElementGetUsage(element)
        let integerValue = IOHIDValueGetIntegerValue(value)
        
        // Process only fn key press events
        if (usagePage == HIDConfig.appleVendorPage || usagePage == HIDConfig.appleVendorPageAlt) && 
           usage == HIDConfig.fnKeyUsage && integerValue == 1 {
            
            let currentTime = CFAbsoluteTimeGetCurrent()
            
            // Debounce control (against too fast presses)
            if currentTime - lastFnPressTime > debounceInterval {
                print("Fn key press detected!")
                lastFnPressTime = currentTime
                
                // Call callback
                onFnKeyPressed?()
            }
        }
    }
    
    /// Checks if the app has Input Monitoring permission
    static func hasInputMonitoringPermission() -> Bool {
        return IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
    }
    
    /// Starts listening
    func startListening() throws {
        // Set shared instance (for callback)
        FnKeyListener.sharedInstance = self
        
        let openResult = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        
        switch openResult {
        case kIOReturnSuccess:
            print("Fn tuşu dinleyicisi aktif!")
            return
        case kIOReturnNotPermitted:
            print("İzin hatası! Giriş İzleme izni gerekli.")
            print("Sistem Ayarları > Gizlilik ve Güvenlik > Giriş İzleme > Terminal")
            throw ListenerError.permissionDenied
        default:
            print("HID Manager hatası: \(openResult)")
            throw ListenerError.hidManagerError(openResult)
        }
    }
    
    /// Stops listening
    func stopListening() {
        print("Fn key listener stopping...")
        IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }
}

// MARK: - Error Types
/// Listener errors
enum ListenerError: Error {
    case permissionDenied
    case hidManagerError(IOReturn)
}
