//
//  AuthRepository.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthRepository {

    private let auth: Auth
    private let usersCollection: CollectionReference

    init(auth: Auth = Auth.auth(), firestore: Firestore = Firestore.firestore()) {
        self.auth = auth
        self.usersCollection = firestore.collection(AppConfig.firestoreUsersCollection)
    }

    func register(email: String, password: String) async throws -> User {
        let result = try await auth.createUserAsync(withEmail: email, password: password)
        let user = User(id: result.user.uid, email: email)
        do {
            try await createUserDocument(user: user)
        } catch {
            if AppConfig.isDebug {
                print("Error creando perfil en Firestore: \(error)")
            }
        }
        storeSession(for: user)
        return user
    }

    func login(email: String, password: String) async throws -> User {
        let result = try await auth.signInAsync(withEmail: email, password: password)
        let uid = result.user.uid

        if let user = try await fetchUser(id: uid) {
            storeSession(for: user)
            return user
        }

        let resolvedEmail = result.user.email ?? email
        let user = User(id: uid, email: resolvedEmail)
        try await ensureUserDocument(user: user)
        storeSession(for: user)
        return user
    }

    func logout() throws {
        try auth.signOut()
        clearSession()
    }

    func currentUser() async throws -> User? {
        guard let firebaseUser = auth.currentUser else {
            clearSession()
            return nil
        }

        if let user = try await fetchUser(id: firebaseUser.uid) {
            storeSession(for: user)
            return user
        }

        let email = firebaseUser.email ?? ""
        let fallbackUser = User(id: firebaseUser.uid, email: email)
        if !email.isEmpty {
            try await ensureUserDocument(user: fallbackUser)
        }
        storeSession(for: fallbackUser)
        return fallbackUser
    }

    private func storeSession(for user: User) {
        KeychainManager.shared.save(key: AppConfig.keychainUserIdKey, value: user.id)
    }

    private func clearSession() {
        KeychainManager.shared.delete(key: AppConfig.keychainUserIdKey)
        KeychainManager.shared.delete(key: AppConfig.keychainTokenKey)
    }

    func searchUsers(query: String, excludingUserId: String? = nil) async throws -> [User] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()

        let snapshot: QuerySnapshot

        if lower.isEmpty {
            snapshot = try await usersCollection
                .limit(to: AppConfig.usersSearchLimit)
                .getDocumentsAsync()
        } else {
            let end = lower + "\u{f8ff}"
            snapshot = try await usersCollection
                .order(by: "emailLowercase")
                .whereField("emailLowercase", isGreaterThanOrEqualTo: lower)
                .whereField("emailLowercase", isLessThanOrEqualTo: end)
                .limit(to: AppConfig.usersSearchLimit)
                .getDocumentsAsync()
        }

        let users = snapshot.documents.compactMap { doc -> User? in
            let data = doc.data()
            let email = data["email"] as? String ?? ""
            return User(id: doc.documentID, email: email)
        }

        if let excludingUserId {
            return users.filter { $0.id != excludingUserId }
        }

        return users
    }

    private func fetchUser(id: String) async throws -> User? {
        let document = try await usersCollection.document(id).getDocumentAsync()
        guard document.exists, let data = document.data() else {
            return nil
        }

        let email = data["email"] as? String ?? ""
        return User(id: document.documentID, email: email)
    }

    private func createUserDocument(user: User) async throws {
        let data: [String: Any] = [
            "email": user.email,
            "emailLowercase": user.email.lowercased(),
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        try await usersCollection.document(user.id).setDataAsync(data)
    }

    private func ensureUserDocument(user: User) async throws {
        let data: [String: Any] = [
            "email": user.email,
            "emailLowercase": user.email.lowercased(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        try await usersCollection.document(user.id).setDataAsync(data, merge: true)
    }
}
