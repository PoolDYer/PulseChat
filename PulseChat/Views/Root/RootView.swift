//
//  RootView.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//


import SwiftUI

struct RootView: View {

    @StateObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated,
               let user = authViewModel.currentUser {

                ChatListView(
                    viewModel: ChatListViewModel(
                        repository: DependencyContainer.shared.chatRepository,
                        currentUser: user
                    ),
                    onLogout: {
                        authViewModel.logout()
                    }
                )

            } else {
                LoginView(viewModel: authViewModel)
            }
        }
        .task {
            await PermissionManager.shared.requestAllPermissions()
        }
    }
}

