//
//  ChatEntity.swift
//  PulseChat
//


import SwiftData
import Foundation

@Model
class ChatEntity {

    @Attribute(.unique) var id: String
    var lastMessage: String
    var lastUpdated: Date
    var participantIds: [String]

    @Relationship(deleteRule: .cascade)
    var messages: [MessageEntity] = []

    @Relationship
    var participants: [UserEntity] = []

    init(
        id: String = UUID().uuidString,
        lastMessage: String = "",
        lastUpdated: Date = Date(),
        participantIds: [String] = []
    ) {
        self.id = id
        self.lastMessage = lastMessage
        self.lastUpdated = lastUpdated
        self.participantIds = participantIds
    }
}	
