
import CoreData

public final class CoreDataFeedStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    // STAR: Critical components/dependencies for the CoreDataStore to work
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }

    func performAsync(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        // STAR: Perform or performAndWait is Thread-Safe in CoreData, so it can be CONCURRENT. If it's not Thread-Safe, the queue should be Serial
        context.perform { action(context) }
    }
    
    // STAR: Sync APIs doesn't need to be @escaping, because doesn't escape.
    func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        // STAR: performAndWait will block the action until its completed
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    
    public func perform(_ action: @escaping () -> Void) {
        context.perform(action)
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}
