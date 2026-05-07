//
//  PulseChatApp.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

import SwiftUI
import FirebaseCore
import SwiftData

@main
struct PulseChatApp: App {

    @StateObject private var appState = AppState()
    @StateObject private var networkMonitor = NetworkMonitor()
    @AppStorage("pulsechat.theme") private var themeMode = ThemeMode.system.rawValue
    @AppStorage("pulsechat.language") private var languageCode = AppLanguage.system.rawValue
    @State private var languageRefreshToken = UUID()

    private let modelContainer: ModelContainer

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        let schema = Schema([
            UserEntity.self,
            ChatEntity.self,
            MessageEntity.self
        ])

        let configuration = ModelConfiguration("PulseChat", schema: schema)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            if AppConfig.isDebug {
                do {
                    let storeURL = configuration.url
                    try FileManager.default.removeItem(at: storeURL)
                    modelContainer = try ModelContainer(for: schema, configurations: [configuration])
                } catch {
                    fatalError("Error inicializando SwiftData tras limpiar store: \(error)")
                }
            } else {
                fatalError("Error inicializando SwiftData: \(error)")
            }
        }

        DependencyContainer.shared.configure(modelContainer: modelContainer)
        LanguageManager.apply(languageCode)
    }

    private var resolvedLocale: Locale {
        let language = AppLanguage(rawValue: languageCode) ?? .system
        guard let code = language.bundleCode else {
            return Locale.autoupdatingCurrent
        }
        return Locale(identifier: code)
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                authViewModel: AuthViewModel(
                    repository: DependencyContainer.shared.authRepository
                )
            )
            .id(languageRefreshToken)
            .environmentObject(appState)
            .environmentObject(networkMonitor)
            .preferredColorScheme(ThemeMode(rawValue: themeMode)?.colorScheme)
            .environment(\.locale, resolvedLocale)
            .onChange(of: languageCode) { _, newValue in
                LanguageManager.apply(newValue)
                languageRefreshToken = UUID()
            }
        }
        .modelContainer(modelContainer)
    }
}


