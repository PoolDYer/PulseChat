import Foundation

protocol ChatAPI {
    func fetchChats(for userId: String) async throws -> [APIChatDTO]
    func fetchMessages(chatId: String) async throws -> [APIMessageDTO]
    func sendMessage(_ message: APIMessageDTO) async throws -> APIMessageDTO
    func createChat(currentUser: APIUserDTO, otherUser: APIUserDTO) async throws -> APIChatDTO
    func updateMessage(chatId: String, messageId: String, newText: String) async throws -> APIMessageDTO
    func deleteMessage(chatId: String, messageId: String) async throws
}

struct APIUserDTO: Codable, Hashable {
    let id: String
    let email: String
}

struct APIChatDTO: Codable, Hashable {
    let id: String
    let participants: [APIUserDTO]
    let lastMessage: String?
    let lastUpdated: Date?
}

struct APIMessageDTO: Codable, Hashable {
    let id: String
    let text: String
    let senderId: String
    let date: Date
    let chatId: String
}
