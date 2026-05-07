//
//  Message.swift
//  PulseChat
//

import Foundation

struct Message: Identifiable, Equatable, Hashable {
    let id: String
    let text: String
    let senderId: String   
    let date: Date
    let chatId: String
    let imageData: Data?

    init(
        id: String,
        text: String,
        senderId: String,
        date: Date,
        chatId: String,
        imageData: Data? = nil
    ) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.date = date
        self.chatId = chatId
        self.imageData = imageData
    }
}
