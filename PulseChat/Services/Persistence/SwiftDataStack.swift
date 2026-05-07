import SwiftData

final class SwiftDataStack {

    let container: ModelContainer
    let context: ModelContext

    init(container: ModelContainer? = nil) {
        if let container {
            self.container = container
        } else {
            do {
                self.container = try ModelContainer(
                    for: UserEntity.self,
                    ChatEntity.self,
                    MessageEntity.self
                )
            } catch {
                fatalError("Error SwiftData: \(error)")
            }
        }

        context = ModelContext(self.container)
    }
}
