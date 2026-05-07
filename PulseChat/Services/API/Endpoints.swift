//
//  Endpoints.swift
//  PulseChat
//
import Foundation


enum Endpoints {
    static let baseURL = AppConfig.apiBaseURL

    static var chats: URL {
        URL(string: "\(baseURL)/chats")!
    }

    static func messages(chatId: String) -> URL {
        URL(string: "\(baseURL)/chats/\(chatId)/messages")!
    }
}
