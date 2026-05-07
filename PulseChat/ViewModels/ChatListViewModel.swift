import Foundation
import Combine

@MainActor
final class ChatListViewModel: ObservableObject {

    // MARK: - State
    @Published var chats: [Chat] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - User
    private let user: User

    var currentUser: User {
        user
    }

    var currentUserId: String {
        user.id
    }

    // MARK: - Dependencies
    private let repository: ChatRepository

    // MARK: - Init
    init(repository: ChatRepository, currentUser: User) {
        self.repository = repository
        self.user = currentUser
    }

    // MARK: - Actions
    func loadChats() async {
        isLoading = true
        errorMessage = nil

        do {
            chats = try await repository.loadChats(for: currentUser.id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

