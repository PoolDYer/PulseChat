import Foundation
import FirebaseAuth
import FirebaseFirestore

extension Auth {
    func signInAsync(withEmail email: String, password: String) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let result = result else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "Auth",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Respuesta vacia de autenticacion"]
                        )
                    )
                    return
                }

                continuation.resume(returning: result)
            }
        }
    }

    func createUserAsync(withEmail email: String, password: String) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let result = result else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "Auth",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Respuesta vacia de autenticacion"]
                        )
                    )
                    return
                }

                continuation.resume(returning: result)
            }
        }
    }
}

extension Query {
    func getDocumentsAsync() async throws -> QuerySnapshot {
        try await withCheckedThrowingContinuation { continuation in
            getDocuments { snapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let snapshot = snapshot else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "Firestore",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Respuesta vacia de Firestore"]
                        )
                    )
                    return
                }

                continuation.resume(returning: snapshot)
            }
        }
    }
}

extension DocumentReference {
    func getDocumentAsync() async throws -> DocumentSnapshot {
        try await withCheckedThrowingContinuation { continuation in
            getDocument { snapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let snapshot = snapshot else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "Firestore",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Respuesta vacia de Firestore"]
                        )
                    )
                    return
                }

                continuation.resume(returning: snapshot)
            }
        }
    }

    func setDataAsync(_ data: [String: Any], merge: Bool = false) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            setData(data, merge: merge) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: ())
            }
        }
    }

    func deleteAsync() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            delete { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: ())
            }
        }
    }
}
