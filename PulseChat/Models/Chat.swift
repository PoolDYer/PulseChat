//
//  Chat.swift
//  PulseChat
//


import Foundation

struct Chat: Identifiable, Equatable, Hashable {
    let id: String
    let participants: [User]
    var lastMessage: String
    var lastUpdated: Date

    func otherUser(currentUserId: String) -> User? {
        participants.first { $0.id != currentUserId }
    }
}
