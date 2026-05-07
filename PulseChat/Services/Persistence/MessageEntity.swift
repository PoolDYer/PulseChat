//
//  MessageEntity.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

import SwiftData
import Foundation

@Model
class MessageEntity {
    @Attribute(.unique) var id: String
    var text: String
    var senderId: String?  
    var date: Date
    var imageData: Data?

    @Relationship var chat: ChatEntity?

    init(
        id: String = UUID().uuidString,
        text: String,
        senderId: String? = nil,
        date: Date = Date(),
        imageData: Data? = nil,
        chat: ChatEntity? = nil
    ) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.date = date
        self.imageData = imageData
        self.chat = chat
    }
}
