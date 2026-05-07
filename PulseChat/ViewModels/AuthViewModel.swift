//
//  AuthViewModel.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var currentUser: User?

    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
        Task {
            await restoreSession()
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await repository.login(email: email, password: password)
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = mapAuthError(error)
            currentUser = nil
            isAuthenticated = false
        }

        isLoading = false
    }

    func register(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await repository.register(email: email, password: password)
            currentUser = user
            isAuthenticated = true
        } catch {
            if let authError = AuthErrorCode(rawValue: (error as NSError).code),
               authError == .emailAlreadyInUse {
                do {
                    let user = try await repository.login(email: email, password: password)
                    currentUser = user
                    isAuthenticated = true
                    errorMessage = AppStrings.errorRegisterExisting
                } catch {
                    errorMessage = mapAuthError(error)
                    currentUser = nil
                    isAuthenticated = false
                }
            } else {
                errorMessage = mapAuthError(error)
                currentUser = nil
                isAuthenticated = false
            }
        }

        isLoading = false
    }

    func logout() {
        do {
            try repository.logout()
        } catch {
            if AppConfig.isDebug {
                print("Error logout: \(error)")
            }
        }
        currentUser = nil
        isAuthenticated = false
    }

    private func restoreSession() async {
        do {
            if let user = try await repository.currentUser() {
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            if AppConfig.isDebug {
                print("Error restoring session: \(error)")
            }
        }
    }

    private func mapAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        guard let code = AuthErrorCode(rawValue: nsError.code) else {
            return error.localizedDescription
        }

        switch code {
        case .invalidEmail:
            return AppStrings.errorAuthInvalidEmail
        case .wrongPassword:
            return AppStrings.errorAuthWrongPassword
        case .userNotFound:
            return AppStrings.errorAuthUserNotFound
        case .emailAlreadyInUse:
            return AppStrings.errorAuthEmailInUse
        case .weakPassword:
            return AppStrings.errorAuthWeakPassword
        case .networkError:
            return AppStrings.errorAuthNetwork
        default:
            return AppStrings.errorAuthDefault
        }
    }
}
