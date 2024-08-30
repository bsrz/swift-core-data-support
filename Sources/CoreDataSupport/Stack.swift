import CoreData

/// The ``Stack`` is used to access the main ``NSManagedObjectContext``
/// and make new background ``NSManagedObjectContext`` instances
public class Stack {

    public let container: NSPersistentContainer

    /// Initializes a new ``Stack``
    /// - Parameters:
    ///   - storeType: The type of store to back the ``Stack``
    ///   - model: The model that should be represented by the ``Stack``
    public init(storeType: StoreType, model: NSManagedObjectModel) {
        let description = NSPersistentStoreDescription()
        description.type = storeType.type
        description.url = storeType.url

        self.container = NSPersistentContainer(name: storeType.name, managedObjectModel: model)
        self.container.persistentStoreDescriptions = [description]
        self.container.loadPersistentStores { description, error in
            guard let error else { return }
            assertionFailure("Unable to load persistent stores: \(error)")
        }
    }

    /// Initializes a new ``Stack``
    /// - Parameter container: The persistent container backing the stack
    public init(container: NSPersistentContainer) {
        self.container = container
    }

    /// The view context
    public var context: NSManagedObjectContext { container.viewContext }

    /// Creates a new background ``NSManagedObjectContext``
    /// - Returns: A new background ``NSManagedObjectContext``
    public func makeBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }

    /// Convenience for saving the view context
    public func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
