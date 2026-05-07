//
//  AppState.swift
//  PulseChat
//

import Foundation
import Combine
import ObjectiveC

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case spanish = "es"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return AppStrings.languageSystem
        case .english:
            return AppStrings.languageEnglish
        case .spanish:
            return AppStrings.languageSpanish
        }
    }

    var bundleCode: String? {
        switch self {
        case .system:
            return nil
        case .english:
            return "en"
        case .spanish:
            return "es"
        }
    }
}

enum LanguageManager {
    static func apply(_ rawValue: String) {
        let language = AppLanguage(rawValue: rawValue) ?? .system
        Bundle.setLanguage(language.bundleCode)
    }
}

enum Localization {
    static func string(_ key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: Bundle.main, value: key, comment: "")
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        let format = string(key)
        return String(format: format, locale: resolvedLocale, arguments: arguments)
    }

    private static var resolvedLocale: Locale {
        let stored = UserDefaults.standard.string(forKey: "pulsechat.language") ?? AppLanguage.system.rawValue
        let language = AppLanguage(rawValue: stored) ?? .system
        if let code = language.bundleCode {
            return Locale(identifier: code)
        }
        return Locale.autoupdatingCurrent
    }
}

private var bundleKey: UInt8 = 0

private final class BundleProxy: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }

        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static func setLanguage(_ languageCode: String?) {
        if object_getClass(Bundle.main) != BundleProxy.self {
            object_setClass(Bundle.main, BundleProxy.self)
        }

        guard let languageCode,
              let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            objc_setAssociatedObject(Bundle.main, &bundleKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return
        }

        objc_setAssociatedObject(Bundle.main, &bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

@MainActor
final class AppState: ObservableObject {

    // MARK: - Global State
    @Published var isAuthenticated: Bool = false

    // MARK: - Init
    init() {
        // Aquí podrías restaurar sesión desde Keychain
        // ejempl
        // if KeychainManager.shared.get(key: "token") != nil {
        //     isAuthenticated = true
        // }
    }

    // MARK: - Actions

    func login() {
        isAuthenticated = true
    }

    func logout() {
        isAuthenticated = false

        // Opcional: limpiar token
        // KeychainManager.shared.delete(key: "token")
    }
}
