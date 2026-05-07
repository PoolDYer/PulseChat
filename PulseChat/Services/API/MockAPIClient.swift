import Foundation

final class MockAPIClient: ChatAPI {

    private let mockUser1 = APIUserDTO(
        id: "user-1",
        email: "juan@test.com"
    )

    private let mockUser2 = APIUserDTO(
        id: "user-2",
        email: "maria@test.com"
    )

    func fetchChats(for userId: String) async throws -> [APIChatDTO] {
        try await Task.sleep(nanoseconds: 400_000_000)

        return [
            APIChatDTO(
                id: "chat-1",
                participants: [mockUser1],
                lastMessage: "Hola",
                lastUpdated: Date()
            ),
            APIChatDTO(
                id: "chat-2",
                participants: [mockUser2],
                lastMessage: "Todo bien?",
                lastUpdated: Date()
            )
        ]
    }

    func fetchMessages(chatId: String) async throws -> [APIMessageDTO] {
        try await Task.sleep(nanoseconds: 300_000_000)

        return []
    }

    func sendMessage(_ message: APIMessageDTO) async throws -> APIMessageDTO {
        try await Task.sleep(nanoseconds: 200_000_000)
        return message
    }

    func createChat(currentUser: APIUserDTO, otherUser: APIUserDTO) async throws -> APIChatDTO {
        try await Task.sleep(nanoseconds: 200_000_000)
        return APIChatDTO(
            id: UUID().uuidString,
            participants: [currentUser, otherUser],
            lastMessage: "",
            lastUpdated: Date()
        )
    }

    func updateMessage(chatId: String, messageId: String, newText: String) async throws -> APIMessageDTO {
        try await Task.sleep(nanoseconds: 200_000_000)
        return APIMessageDTO(
            id: messageId,
            text: newText,
            senderId: mockUser1.id,
            date: Date(),
            chatId: chatId
        )
    }

    func deleteMessage(chatId: String, messageId: String) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
    }
}
