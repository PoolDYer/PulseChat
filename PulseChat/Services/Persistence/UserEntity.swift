//
//  UserEntity.swift
//  PulseChat
//

import SwiftData
import Foundation

@Model
final class UserEntity {
    @Attribute(.unique) var id: String
    var email: String

    @Relationship
    var chats: [ChatEntity] = []

    init(id: String = UUID().uuidString, email: String) {
        self.id = id
        self.email = email
    }
}
