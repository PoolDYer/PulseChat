import Foundation
import FirebaseFirestore
import SwiftData

@MainActor
final class ChatRepository {

    private let chatsCollection: CollectionReference
    private let context: ModelContext

    init(firestore: Firestore = Firestore.firestore(), dataStack: SwiftDataStack) {
        self.chatsCollection = firestore.collection(AppConfig.firestoreChatsCollection)
        self.context = dataStack.context
    }

    // MARK: - Chats
    func loadChats(for userId: String) async throws -> [Chat] {
        let localChats = try getChats(for: userId)

        do {
            let snapshot = try await chatsCollection
                .whereField("participantIds", arrayContains: userId)
                .getDocumentsAsync()
            try upsertChats(snapshot.documents)
        } catch {
            if AppConfig.isDebug {
                print("Error sync chats: \(error)")
            }
            if !localChats.isEmpty {
                return localChats
            }
            throw error
        }

        return try getChats(for: userId)
    }

    // MARK: - Messages
    func loadMessages(chatId: String) async throws -> [Message] {
        let localMessages = try getMessages(chatId: chatId)

        do {
            let snapshot = try await chatsCollection
                .document(chatId)
                .collection(AppConfig.firestoreMessagesCollection)
                .order(by: "date", descending: false)
                .getDocumentsAsync()
            try upsertMessages(snapshot.documents, chatId: chatId)
        } catch {
            if AppConfig.isDebug {
                print("Error sync messages: \(error)")
            }
            if !localMessages.isEmpty {
                return localMessages
            }
            throw error
        }

        return try getMessages(chatId: chatId)
    }

    // MARK: - Send Message
    func sendMessage(_ message: Message) async throws -> Message {
        let chatRef = chatsCollection.document(message.chatId)
        let messagesRef = chatRef.collection(AppConfig.firestoreMessagesCollection)
        let resolvedId = message.id.isEmpty ? messagesRef.document().documentID : message.id

        let resolvedMessage = Message(
            id: resolvedId,
            text: message.text,
            senderId: message.senderId,
            date: message.date,
            chatId: message.chatId,
            imageData: message.imageData
        )

        let hasText = !resolvedMessage.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if hasText {
            let data: [String: Any] = [
                "text": resolvedMessage.text,
                "senderId": resolvedMessage.senderId,
                "date": resolvedMessage.date
            ]

            try await messagesRef.document(resolvedId).setDataAsync(data)

            try await chatRef.setDataAsync(
                [
                    "lastMessage": resolvedMessage.text,
                    "lastUpdated": FieldValue.serverTimestamp()
                ],
                merge: true
            )
        }

        let chat = try getOrCreateChatEntity(id: resolvedMessage.chatId)
        try upsertMessage(resolvedMessage, chat: chat)
        chat.lastMessage = hasText ? resolvedMessage.text : AppStrings.imageMessageFallback
        chat.lastUpdated = Date()
        try context.save()

        return resolvedMessage
    }

    // MARK: - Edit Message
    func updateMessage(_ message: Message, newText: String) async throws -> Message {
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)

        let messageRef = chatsCollection
            .document(message.chatId)
            .collection(AppConfig.firestoreMessagesCollection)
            .document(message.id)

        try await messageRef.setDataAsync(["text": trimmed], merge: true)

        if let entity = try fetchMessageEntity(id: message.id) {
            entity.text = trimmed
            try context.save()
        }

        return Message(
            id: message.id,
            text: trimmed,
            senderId: message.senderId,
            date: message.date,
            chatId: message.chatId,
            imageData: message.imageData
        )
    }

    // MARK: - Delete Message
    func deleteMessage(_ message: Message) async throws {
        let messageRef = chatsCollection
            .document(message.chatId)
            .collection(AppConfig.firestoreMessagesCollection)
            .document(message.id)

        try await messageRef.deleteAsync()

        if let entity = try fetchMessageEntity(id: message.id) {
            context.delete(entity)
            try context.save()
        }
    }

    // MARK: - Create Chat
    func createChat(currentUser: User, otherUser: User) async throws -> Chat {
        let snapshot = try await chatsCollection
            .whereField("participantIds", arrayContains: currentUser.id)
            .getDocumentsAsync()

        if let existing = snapshot.documents.first(where: { document in
            let data = document.data()
            let participantIds = data["participantIds"] as? [String] ?? []
            return participantIds.contains(otherUser.id)
        }) {
            let entity = try upsertChat(existing)
            try context.save()
            return mapChatEntity(entity)
        }

        let chatRef = chatsCollection.document()
        let participantIds = [currentUser.id, otherUser.id]
        let participantEmailsById = [
            currentUser.id: currentUser.email,
            otherUser.id: otherUser.email
        ]

        let data: [String: Any] = [
            "participantIds": participantIds,
            "participantEmailsById": participantEmailsById,
            "lastMessage": "",
            "lastUpdated": FieldValue.serverTimestamp()
        ]

        try await chatRef.setDataAsync(data)

        let entity = try upsertChatData(
            chatId: chatRef.documentID,
            participants: [currentUser, otherUser],
            lastMessage: "",
            lastUpdated: Date()
        )
        try context.save()

        return mapChatEntity(entity)
    }

    // MARK: - Local Fetch
    private func getChats(for userId: String) throws -> [Chat] {
        let descriptor = FetchDescriptor<ChatEntity>()
        let entities = try context.fetch(descriptor)

        return entities
            .filter { chat in
                if !chat.participantIds.isEmpty {
                    return chat.participantIds.contains(userId)
                }

                return chat.participants.contains { $0.id == userId }
            }
            .map { mapChatEntity($0) }
            .sorted { $0.lastUpdated > $1.lastUpdated }
    }

    private func getMessages(chatId: String) throws -> [Message] {
        let id = chatId
        let descriptor = FetchDescriptor<MessageEntity>(
            predicate: #Predicate { message in
                message.chat?.id == id
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        let entities = try context.fetch(descriptor)
        return entities.map { mapMessageEntity($0, chatId: chatId) }
    }

    // MARK: - Upsert
    private func upsertChats(_ documents: [QueryDocumentSnapshot]) throws {
        for document in documents {
            _ = try upsertChat(document)
        }

        try context.save()
    }

    private func upsertMessages(_ documents: [QueryDocumentSnapshot], chatId: String) throws {
        let chat = try getOrCreateChatEntity(id: chatId)

        for document in documents {
            try upsertMessage(document, chat: chat)
        }

        try context.save()
    }

    private func upsertChat(_ document: DocumentSnapshot) throws -> ChatEntity {
        let entity = try getOrCreateChatEntity(id: document.documentID)

        guard let data = document.data() else {
            return entity
        }

        let participantEmailsById = parseParticipantEmails(value: data["participantEmailsById"])
        let participantIds = parseParticipantIds(value: data["participantIds"]) ?? participantEmailsById.map { $0.key }

        entity.lastMessage = data["lastMessage"] as? String ?? ""
        entity.lastUpdated = parseDate(value: data["lastUpdated"]) ?? Date.distantPast
        entity.participantIds = participantIds
        entity.participants = try participantIds.map { id in
            let email = participantEmailsById[id] ?? "Desconocido"
            return try upsertUser(id: id, email: email)
        }

        return entity
    }

    private func upsertChatData(
        chatId: String,
        participants: [User],
        lastMessage: String,
        lastUpdated: Date
    ) throws -> ChatEntity {
        let entity = try getOrCreateChatEntity(id: chatId)
        entity.lastMessage = lastMessage
        entity.lastUpdated = lastUpdated
        entity.participantIds = participants.map { $0.id }
        entity.participants = try participants.map { user in
            try upsertUser(id: user.id, email: user.email)
        }
        return entity
    }

    private func upsertMessage(_ document: DocumentSnapshot, chat: ChatEntity) throws {
        let id = document.documentID
        let data = document.data() ?? [:]
        let text = data["text"] as? String ?? ""
        let senderId = data["senderId"] as? String
        let date = parseDate(value: data["date"]) ?? Date()

        let descriptor = FetchDescriptor<MessageEntity>(
            predicate: #Predicate { item in
                item.id == id
            }
        )

        if let existing = try context.fetch(descriptor).first {
            existing.text = text
            existing.senderId = senderId
            existing.date = date
            existing.chat = chat
            return
        }

        let entity = MessageEntity(
            id: id,
            text: text,
            senderId: senderId,
            date: date,
            imageData: nil,
            chat: chat
        )

        context.insert(entity)
    }

    private func upsertMessage(_ message: Message, chat: ChatEntity) throws {
        let id = message.id
        let descriptor = FetchDescriptor<MessageEntity>(
            predicate: #Predicate { item in
                item.id == id
            }
        )

        if let existing = try context.fetch(descriptor).first {
            existing.text = message.text
            existing.senderId = message.senderId
            existing.date = message.date
            existing.chat = chat
            if let imageData = message.imageData {
                existing.imageData = imageData
            }
            return
        }

        let entity = MessageEntity(
            id: message.id,
            text: message.text,
            senderId: message.senderId,
            date: message.date,
            imageData: message.imageData,
            chat: chat
        )

        context.insert(entity)
    }

    private func fetchMessageEntity(id: String) throws -> MessageEntity? {
        let descriptor = FetchDescriptor<MessageEntity>(
            predicate: #Predicate { item in
                item.id == id
            }
        )

        return try context.fetch(descriptor).first
    }

    private func upsertUser(id: String, email: String) throws -> UserEntity {
        let descriptor = FetchDescriptor<UserEntity>(
            predicate: #Predicate { item in
                item.id == id
            }
        )

        if let existing = try context.fetch(descriptor).first {
            if existing.email != email {
                existing.email = email
            }
            return existing
        }

        let entity = UserEntity(id: id, email: email)
        context.insert(entity)
        return entity
    }

    private func getOrCreateChatEntity(id: String) throws -> ChatEntity {
        let descriptor = FetchDescriptor<ChatEntity>(
            predicate: #Predicate { item in
                item.id == id
            }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let entity = ChatEntity(id: id)
        context.insert(entity)
        return entity
    }

    // MARK: - Mapping
    private func mapChatEntity(_ entity: ChatEntity) -> Chat {
        let participants: [User]

        if !entity.participants.isEmpty {
            participants = entity.participants.map { User(id: $0.id, email: $0.email) }
        } else if !entity.participantIds.isEmpty {
            participants = entity.participantIds.map { id in
                let email = (try? fetchUserEntity(id: id))?.email ?? "Desconocido"
                return User(id: id, email: email)
            }
        } else {
            participants = []
        }

        return Chat(
            id: entity.id,
            participants: participants,
            lastMessage: entity.lastMessage,
            lastUpdated: entity.lastUpdated
        )
    }

    private func mapMessageEntity(_ entity: MessageEntity, chatId: String) -> Message {
        Message(
            id: entity.id,
            text: entity.text,
            senderId: entity.senderId ?? "",
            date: entity.date,
            chatId: chatId,
            imageData: entity.imageData
        )
    }

    private func parseDate(value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }

        if let date = value as? Date {
            return date
        }

        return nil
    }

    private func parseParticipantIds(value: Any?) -> [String]? {
        if let ids = value as? [String] {
            return ids
        }

        if let ids = value as? [Any] {
            let parsed = ids.compactMap { $0 as? String }
            return parsed.isEmpty ? nil : parsed
        }

        if let ids = value as? NSArray {
            let parsed = ids.compactMap { $0 as? String }
            return parsed.isEmpty ? nil : parsed
        }

        return nil
    }

    private func parseParticipantEmails(value: Any?) -> [String: String] {
        if let emails = value as? [String: String] {
            return emails
        }

        if let emails = value as? [String: Any] {
            return emails.compactMapValues { $0 as? String }
        }

        return [:]
    }

    private func fetchUserEntity(id: String) throws -> UserEntity? {
        let descriptor = FetchDescriptor<UserEntity>(
            predicate: #Predicate { item in
                item.id == id
            }
        )

        return try context.fetch(descriptor).first
    }
}
