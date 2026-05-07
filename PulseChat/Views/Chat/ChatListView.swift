//
//  ChatListView.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

import SwiftUI

struct ChatListView: View {

    @StateObject var viewModel: ChatListViewModel
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    let onLogout: () -> Void

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            onLogout()
                        } label: {
                            Text(AppStrings.logout)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.15))
                                .foregroundColor(.red)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.red.opacity(0.35), lineWidth: 1)
                                )
                        }
                        .contentShape(Rectangle())
                        .padding(.leading, 4)
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SearchUserView(
                                viewModel: SearchUserViewModel(
                                    currentUser: viewModel.currentUser,
                                    authRepository: DependencyContainer.shared.authRepository,
                                    chatRepository: DependencyContainer.shared.chatRepository
                                )
                            )
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        .accessibilityLabel(AppStrings.searchUsersTitle)
                        .accessibilityHint(AppStrings.searchUsersHint)
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.loadChats()
                    }
                }
                .refreshable {
                    await viewModel.loadChats()
                }
                .navigationDestination(for: Chat.self) { chat in
                    ChatDetailView(
                        viewModel: ChatDetailViewModel(
                            chatId: chat.id,
                            currentUserId: viewModel.currentUserId,
                            repository: DependencyContainer.shared.chatRepository
                        ),
                        chatTitle: chatDisplayName(chat)
                    )
                }
        }
    }
}

// MARK: - UI States
private extension ChatListView {

    @ViewBuilder
    var content: some View {
        VStack(spacing: 0) {
            ThemePickerView()
            LanguagePickerView()

            Text(AppStrings.chats)
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 4)

            if !networkMonitor.isConnected {
                offlineBanner
            }

            if viewModel.isLoading {
                LoadingView()
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error)
            } else if viewModel.chats.isEmpty {
                EmptyStateView(message: AppStrings.emptyChats)
            } else {
                chatList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    var chatList: some View {
        List(sortedChats) { chat in
            NavigationLink(value: chat) {
                ChatRowView(
                    chat: chat,
                    currentUserId: viewModel.currentUserId
                )
            }
        }
        .listStyle(.plain)
    }

    // ✅ Ordenar por último mensaje
    var sortedChats: [Chat] {
        viewModel.chats.sorted {
            $0.lastUpdated > $1.lastUpdated
        }
    }

    // ✅ Mostrar SOLO el otro usuario
    func chatDisplayName(_ chat: Chat) -> String {
        let others = chat.participants.filter {
            $0.id != viewModel.currentUserId
        }

        if others.isEmpty {
            return AppStrings.you
        }

        return others
            .map { $0.email }
            .joined(separator: ", ")
    }

    var offlineBanner: some View {
        Text(AppStrings.offlineBanner)
            .font(.footnote)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color.yellow.opacity(0.2))
            .foregroundColor(.orange)
    }
}
