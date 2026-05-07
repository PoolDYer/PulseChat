//
//  Config.swift
//  PulseChat
//

import Foundation

enum AppConfig {
    static let isDebug = true
    static let apiTimeout: TimeInterval = 15
    static let apiBaseURL = "https://mockapi.io"
    static let firestoreUsersCollection = "users"
    static let firestoreChatsCollection = "chats"
    static let firestoreMessagesCollection = "messages"
    static let usersSearchLimit = 50
    static let keychainTokenKey = "pulsechat.session.token"
    static let keychainUserIdKey = "pulsechat.session.userId"
}
