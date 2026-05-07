//
//  SearchUserViewModel.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

import Foundation
import Combine

@MainActor
final class SearchUserViewModel: ObservableObject {

    @Published var searchText = ""
    @Published var results: [User] = []
    @Published var errorMessage: String?

    let currentUser: User

    private let authRepository: AuthRepository
    private let chatRepository: ChatRepository

    init(currentUser: User,
         authRepository: AuthRepository,
         chatRepository: ChatRepository) {
        self.currentUser = currentUser
        self.authRepository = authRepository
        self.chatRepository = chatRepository
    }

    func searchUsers() async {
        errorMessage = nil
        do {
            results = try await authRepository.searchUsers(
                query: searchText,
                excludingUserId: currentUser.id
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createChat(with user: User) async -> Chat? {
        errorMessage = nil
        do {
            return try await chatRepository.createChat(
                currentUser: currentUser,
                otherUser: user
            )
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
