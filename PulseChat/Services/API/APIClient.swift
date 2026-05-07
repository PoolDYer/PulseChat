//
//  APIClient.swift
//  PulseChat
/
//
import Foundation

final class APIClient: ChatAPI {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = .shared) {
        self.session = session

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    func fetchChats(for userId: String) async throws -> [APIChatDTO] {
        let request = makeRequest(url: Endpoints.chats, method: "GET")
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode([APIChatDTO].self, from: data)
    }

    func fetchMessages(chatId: String) async throws -> [APIMessageDTO] {
        let request = makeRequest(
            url: Endpoints.messages(chatId: chatId),
            method: "GET"
        )

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode([APIMessageDTO].self, from: data)
    }

    func sendMessage(_ message: APIMessageDTO) async throws -> APIMessageDTO {
        var request = makeRequest(
            url: Endpoints.messages(chatId: message.chatId),
            method: "POST"
        )

        request.httpBody = try encoder.encode(message)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)

        do {
            return try decoder.decode(APIMessageDTO.self, from: data)
        } catch {
            return message
        }
    }

    func createChat(currentUser: APIUserDTO, otherUser: APIUserDTO) async throws -> APIChatDTO {
        let request = makeRequest(url: Endpoints.chats, method: "POST")
        let payload = APIChatDTO(
            id: UUID().uuidString,
            participants: [currentUser, otherUser],
            lastMessage: "",
            lastUpdated: Date()
        )

        var mutable = request
        mutable.httpBody = try encoder.encode(payload)

        let (data, response) = try await session.data(for: mutable)
        try validateResponse(response)

        do {
            return try decoder.decode(APIChatDTO.self, from: data)
        } catch {
            return payload
        }
    }

    func updateMessage(chatId: String, messageId: String, newText: String) async throws -> APIMessageDTO {
        let request = makeRequest(
            url: Endpoints.messages(chatId: chatId),
            method: "PUT"
        )

        let payload = APIMessageDTO(
            id: messageId,
            text: newText,
            senderId: "",
            date: Date(),
            chatId: chatId
        )

        var mutable = request
        mutable.httpBody = try encoder.encode(payload)

        let (data, response) = try await session.data(for: mutable)
        try validateResponse(response)

        do {
            return try decoder.decode(APIMessageDTO.self, from: data)
        } catch {
            return payload
        }
    }

    func deleteMessage(chatId: String, messageId: String) async throws {
        let request = makeRequest(
            url: Endpoints.messages(chatId: chatId),
            method: "DELETE"
        )

        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }

    private func makeRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = AppConfig.apiTimeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpStatus(httpResponse.statusCode)
        }
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return AppStrings.errorApiInvalidResponse
        case .httpStatus(let code):
            return AppStrings.httpError(code)
        }
    }
}

