import SwiftUI

struct SearchUserView: View {

    @StateObject var viewModel: SearchUserViewModel

    
    @State private var selectedChat: Chat?

    var body: some View {
        VStack {

            // MARK: - Buscador
            HStack {
                TextField(AppStrings.searchPlaceholder, text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)

                Button(AppStrings.search) {
                    Task {
                        await viewModel.searchUsers()
                    }
                }
            }
            .padding()

            // MARK: - Lista
            List(viewModel.results) { user in
                Button {
                    Task {
                        if let chat = await viewModel.createChat(with: user) {
                            selectedChat = chat
                        }
                    }
                } label: {
                    HStack {
                        Text(user.email)
                        Spacer()
                        Image(systemName: "message")
                    }
                }
            }

            if let error = viewModel.errorMessage {
                ErrorView(message: error)
            }
        }
        .navigationTitle(AppStrings.searchUsersTitle)

        //  API NUEVA
        .navigationDestination(item: $selectedChat) { chat in
            ChatDetailView(
                viewModel: ChatDetailViewModel(
                    chatId: chat.id,
                    currentUserId: viewModel.currentUser.id, 
                    repository: DependencyContainer.shared.chatRepository
                ),
                chatTitle: chat.participants.map { $0.email }.joined(separator: ", ")
            )
        }
    }
}
