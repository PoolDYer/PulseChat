import Foundation
import Combine
import UIKit

@MainActor
final class ChatDetailViewModel: ObservableObject {

    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var attachedImage: UIImage?
    @Published var editingMessageId: String?

    private let repository: ChatRepository
    let chatId: String
    let currentUserId: String   // 🔥 EXPONER (no private)

    private var lastSeenKey: String {
        "pulsechat.lastSeen.\(chatId)"
    }

    init(chatId: String, currentUserId: String, repository: ChatRepository) {
        self.chatId = chatId
        self.currentUserId = currentUserId
        self.repository = repository
    }

    func loadMessages() async {
        isLoading = true
        errorMessage = nil

        let previousLastSeen = lastSeenDate()

        do {
            messages = try await repository.loadMessages(chatId: chatId)

            if let previousLastSeen {
                notifyIfNeeded(since: previousLastSeen)
            }
            updateLastSeen(Date())
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func sendMessage() async {
        if let editingMessageId {
            await updateMessage(editingMessageId: editingMessageId)
            return
        }

        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || attachedImage != nil else { return }

        let imageData = attachedImage?.jpegData(compressionQuality: 0.8)

        let message = Message(
            id: UUID().uuidString,
            text: trimmed,
            senderId: currentUserId, // 🔥 AQUÍ ESTÁ LA MAGIA
            date: Date(),
            chatId: chatId,
            imageData: imageData
        )

        do {
            let sent = try await repository.sendMessage(message)
            messages.append(sent)
            messageText = ""
            attachedImage = nil
        } catch {
            messages.append(message)
            messageText = ""
            attachedImage = nil
            errorMessage = AppStrings.errorSendMessage
        }
    }

    func startEditing(_ message: Message) {
        editingMessageId = message.id
        messageText = message.text
        attachedImage = nil
    }

    func cancelEditing() {
        editingMessageId = nil
        messageText = ""
        attachedImage = nil
    }

    func deleteMessage(_ message: Message) async {
        do {
            try await repository.deleteMessage(message)
            messages.removeAll { $0.id == message.id }

            if editingMessageId == message.id {
                cancelEditing()
            }
        } catch {
            errorMessage = AppStrings.errorDeleteMessage
        }
    }

    func attachImage(_ image: UIImage) {
        attachedImage = image
    }

    func removeAttachment() {
        attachedImage = nil
    }

    private func updateMessage(editingMessageId: String) async {
        guard let index = messages.firstIndex(where: { $0.id == editingMessageId }) else {
            cancelEditing()
            return
        }

        let original = messages[index]
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasContent = !trimmed.isEmpty || original.imageData != nil

        guard hasContent else {
            errorMessage = AppStrings.errorMessageRequired
            return
        }

        do {
            let updated = try await repository.updateMessage(original, newText: trimmed)
            messages[index] = updated
            cancelEditing()
        } catch {
            errorMessage = AppStrings.errorEditMessage
        }
    }

    private func notifyIfNeeded(since date: Date) {
        let incoming = messages.filter {
            $0.senderId != currentUserId && $0.date > date
        }

        guard let latest = incoming.last else {
            return
        }

        NotificationManager.shared.notifyNewMessage(
            title: AppStrings.appName,
            body: latest.text
        )
    }

    private func lastSeenDate() -> Date? {
        UserDefaults.standard.object(forKey: lastSeenKey) as? Date
    }

    private func updateLastSeen(_ date: Date) {
        UserDefaults.standard.set(date, forKey: lastSeenKey)
    }
}
