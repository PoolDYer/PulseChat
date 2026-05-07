//
//  Chat.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
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
