//
//  AppTheme.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

import SwiftUI

struct AppTheme {

    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16

    static let shadow = Color.black.opacity(0.1)
}

enum ThemeMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return AppStrings.themeSystem
        case .light:
            return AppStrings.themeLight
        case .dark:
            return AppStrings.themeDark
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}


