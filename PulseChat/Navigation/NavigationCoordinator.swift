import SwiftUI
import Combine

// Rutas de la app
enum AppRoute: Hashable {
    case chats
    case chatDetail(String, title: String)
}

// Coordinador simple con NavigationPath
@MainActor
final class NavigationCoordinator: ObservableObject {

    @Published var path = NavigationPath()

    func goToChatList() {
        path = NavigationPath() // reset
        path.append(AppRoute.chats)
    }

    func goToChatDetail(id: String, title: String) {
        path.append(AppRoute.chatDetail(id, title: title))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func reset() {
        path = NavigationPath()
    }
}
