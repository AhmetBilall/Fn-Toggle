import Foundation

// MARK: - Language
enum Language: String, Codable {
    case turkish = "tr"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        }
    }
}

// MARK: - Localizable
struct Localizable {
    private static let languageKey = "AppLanguage"
    
    static var currentLanguage: Language {
        get {
            if let savedLang = UserDefaults.standard.string(forKey: languageKey),
               let language = Language(rawValue: savedLang) {
                return language
            }
            return .english // Default
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: languageKey)
        }
    }
    
    // MARK: - Menu Items
    struct Menu {
        static var toggleFnState: String {
            currentLanguage == .turkish 
                ? "Fn Durumunu Değiştir" 
                : "Toggle Fn State"
        }
        
        static var clearFnAction: String {
            currentLanguage == .turkish 
                ? "Sistem Fn Görevini Temizle" 
                : "Clear System Fn Action"
        }
        
        static var clearFnActionTooltip: String {
            currentLanguage == .turkish 
                ? "Fn tuşunun sistem atamasını (örn. Emoji, Dikte) kaldırır" 
                : "Removes system assignment (e.g. Emoji, Dictation) from Fn key"
        }
        
        static var launchAtLogin: String {
            currentLanguage == .turkish 
                ? "Başlangıçta Aç" 
                : "Launch at Login"
        }
        
        static var language: String {
            currentLanguage == .turkish 
                ? "Dil" 
                : "Language"
        }
        
        static var about: String {
            currentLanguage == .turkish 
                ? "Hakkında" 
                : "About"
        }
        
        static var quit: String {
            currentLanguage == .turkish 
                ? "Çıkış" 
                : "Quit"
        }
    }
    
    // MARK: - Status Messages
    struct Status {
        static var functionKeys: String {
            currentLanguage == .turkish 
                ? "Fn Tuşları: Fonksiyon Tuşları" 
                : "Fn Keys: Function Keys"
        }
        
        static var multimediaKeys: String {
            currentLanguage == .turkish 
                ? "Fn Tuşları: Multimedia Tuşları" 
                : "Fn Keys: Multimedia Keys"
        }
    }
    
    // MARK: - Alerts
    struct Alert {
        // Permission Alert
        static var permissionTitle: String {
            currentLanguage == .turkish 
                ? "Giriş İzleme İzni Gerekli" 
                : "Input Monitoring Permission Required"
        }
        
        static var permissionMessage: String {
            currentLanguage == .turkish 
                ? """
                Fn tuşu değiştiricisinin çalışabilmesi için uygulamanın klavye girişlerini izleme iznine ihtiyacı var.
                
                "Sistem Ayarlarını Aç" butonuna tıklayarak Gizlilik ve Güvenlik ayarlarından izni verebilirsiniz.
                
                İzni verdikten sonra uygulamayı yeniden başlatmanız gerekecektir.
                """
                : """
                The Fn key toggle app needs permission to monitor keyboard inputs.
                
                Click "Open System Settings" to grant permission from Privacy & Security settings.
                
                You'll need to restart the app after granting permission.
                """
        }
        
        static var openSettings: String {
            currentLanguage == .turkish 
                ? "Sistem Ayarlarını Aç" 
                : "Open System Settings"
        }
        
        // Clear Fn Action Alert
        static var fnActionClearedTitle: String {
            currentLanguage == .turkish 
                ? "Sistem Fn Görevi Temizlendi" 
                : "System Fn Action Cleared"
        }
        
        static var fnActionClearedMessage: String {
            currentLanguage == .turkish 
                ? "Fn tuşunun sistem ataması (Emoji, Dikte vb.) 'Hiçbir Şey Yapma' olarak ayarlandı.\n\nArtık Fn tuşu sadece bu uygulama tarafından kullanılacak."
                : "The Fn key's system assignment (Emoji, Dictation, etc.) has been set to 'Do Nothing'.\n\nThe Fn key will now only be used by this app."
        }
        
        // About Alert
        static var aboutTitle: String {
            currentLanguage == .turkish 
                ? "Fn Key Toggle" 
                : "Fn Key Toggle"
        }
        
        static var aboutMessage: String {
            currentLanguage == .turkish 
                ? """
                macOS için Fn tuşu durumu değiştiricisi
                
                Fn tuşuna basarak klavye ayarını değiştirin
                Ses geri bildirimi ile
                Menu bar'dan kolay erişim
                
                Versiyon: 1.0.0
                """
                : """
                Fn key state toggles for macOS
                
                Press Fn key to change keyboard settings
                With audio feedback
                Easy access from menu bar
                
                Version: 1.0.0
                """
        }
        
        static var ok: String {
            currentLanguage == .turkish 
                ? "Tamam" 
                : "OK"
        }
    }
    
    // MARK: - Console Messages (Optional)
    struct Console {
        static var fnKeyPressed: String {
            currentLanguage == .turkish 
                ? "Fn tuşu basıldı!" 
                : "Fn key pressed!"
        }
        
        static var listenerActive: String {
            currentLanguage == .turkish 
                ? "Fn tuşu dinleyicisi aktif!" 
                : "Fn key listener active!"
        }
        
        static var permissionError: String {
            currentLanguage == .turkish 
                ? "İzin hatası! Giriş İzleme izni gerekli." 
                : "Permission error! Input Monitoring permission required."
        }
        
        static var stateChanged: String {
            currentLanguage == .turkish 
                ? "Fn durumu değişti" 
                : "Fn state changed"
        }
        
        static var functionMode: String {
            currentLanguage == .turkish 
                ? "Fonksiyon" 
                : "Function"
        }
        
        static var multimediaMode: String {
            currentLanguage == .turkish 
                ? "Multimedia" 
                : "Multimedia"
        }
    }
}
