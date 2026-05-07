import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftData

final class DependencyContainer {

    static let shared = DependencyContainer()
    private init() {
        auth = Auth.auth()
        firestore = Firestore.firestore()
    }

    // MARK: - Core
    private var dataStack: SwiftDataStack?
    private let auth: Auth
    private let firestore: Firestore

    func configure(modelContainer: ModelContainer) {
        if dataStack == nil {
            dataStack = SwiftDataStack(container: modelContainer)
        }
    }

    private var resolvedDataStack: SwiftDataStack {
        guard let dataStack else {
            preconditionFailure("DependencyContainer not configured with ModelContainer")
        }
        return dataStack
    }

    // MARK: - Repositories
    lazy var authRepository: AuthRepository = {
        AuthRepository(auth: auth, firestore: firestore)
    }()

    lazy var chatRepository: ChatRepository = {
        ChatRepository(firestore: firestore, dataStack: resolvedDataStack)
    }()
}
