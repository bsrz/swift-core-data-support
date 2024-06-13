import CoreData

/// Use a ``StackBuilder`` instance to migrate a persistent store and create a ``Stack`` instance
public class StackBuilder {

    let bundle: Bundle
    let currentModel: NSManagedObjectModel
    let enabledMigrations: Bool
    let fileManager: FileManager
    let modelDirectory: String
    let modelName: String
    let storeType: StoreType

    /// Initializes a new ``MigrationManager``
    /// - Parameters:
    ///   - modelDirectory: Only the name of the directory containing all models (do not include the `xcdatamodeld` suffix)
    ///   - modelName: Only the name of the model (do not include the `xcdatamodel` suffix)
    ///   - bundle: The bundle in which the the compiled models can be found
    ///   - storeType: The type of backing store to use (e.g. in memory, or on disk)
    ///   - enabledMigrations: If `true` an attempt to migrate the existing backing store will be made
    ///   - fileManager: The file manager to use to manage on disk backing stores
    public init(modelDirectory: String, modelName: String, in bundle: Bundle, storeType: StoreType, enabledMigrations: Bool, fileManager: FileManager = .default) {
        self.bundle = bundle
        self.currentModel = .model(inDirectory: modelDirectory, named: modelName, in: bundle)
        self.enabledMigrations = enabledMigrations
        self.fileManager = fileManager
        self.modelDirectory = modelDirectory
        self.modelName = modelName
        self.storeType = storeType
    }

    /// Creates a new stack and attempts to migrate the store (if enabled) in the process
    ///
    /// The caller should be retaining the stack as needed.
    ///
    /// - Returns: A new stack
    public func makeStack() -> Stack {
        switch storeType {
        case .inMemory:
            return Stack(storeType: storeType, model: currentModel)

        case .onDisk:
            guard enabledMigrations, !isStore(at: storeType.url, compatibleWithModel: currentModel) else {
                return Stack(storeType: storeType, model: currentModel)
            }

            performMigrations()

            return Stack(storeType: storeType, model: currentModel)
        }
    }

    /// Determines if a store at a given ``URL`` is compatible with a given ``NSManagedObjectModel``
    /// - Parameters:
    ///   - url: The ``URL`` of the store on disk
    ///   - model: The ``NSManagedObjectContext`` used for compatibility check
    /// - Returns: `true` if the store is compatible, `false` othewise
    private func isStore(at url: URL, compatibleWithModel model: NSManagedObjectModel) -> Bool {
        do {
            let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(type: .sqlite, at: storeType.url)
            return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        } catch {
            assert(!fileManager.fileExists(atPath: url.path()), "Unexpected error while fetching metadata for store at: \(url)")
            return false
        }
    }

    /// Migrates the persistent store using all models in sequential, ascending order (numerical, or alphabetical)
    ///
    /// Migrates from Model0 to Model1, then from Model1 to Model2, etc...
    func performMigrations() {
        guard fileManager.fileExists(atPath: storeType.url.absoluteURL.path()) else { return }

        let models = NSManagedObjectModel.models(inDirectory: modelDirectory, in: bundle)
        guard var previous = models.first else { return }

        for next in models.dropFirst() {
            guard previous != currentModel else { break }

            do {
                try migrateStore(at: storeType.url, from: previous, to: next)
                previous = next
            } catch {
                assertionFailure("Unable to migrate the store from \(previous.entityVersionHashesByName) to \(next.entityVersionHashesByName)")
                break
            }
        }
    }

    /// Attempts to migrate a store at a given ``URL`` from a source ``NSManagedObjectModel``
    /// to a destination ``NSManagedObjectModel`` using an optional ``NSMappingModel``
    ///
    /// - Parameters:
    ///   - url: The ``URL`` of the store to migrate
    ///   - source: The source ``NSManagedObjectModel``
    ///   - destination: The destination ``NSManagedObjectModel``
    ///   - mapping: The ``NSMappingModel`` to use during the migration
    private func migrateStore(at url: URL, from source: NSManagedObjectModel, to destination: NSManagedObjectModel, mapping: NSMappingModel? = nil) throws {
        let manager = NSMigrationManager(
            sourceModel: source,
            destinationModel: destination
        )
        let mapping = try mapping ?? NSMappingModel.inferredMappingModel(
            forSourceModel: source,
            destinationModel: destination
        )

        let targetUrl = url.deletingLastPathComponent()
        let destinationName = url.lastPathComponent + "-1"
        let destinationUrl = targetUrl.appending(path: destinationName)

        try manager.migrateStore(
            from: url,
            type: .sqlite,
            mapping: mapping,
            to: destinationUrl,
            type: .sqlite
        )

        try fileManager.removeItem(at: storeType.url)
        try fileManager.moveItem(at: destinationUrl, to: storeType.url)
    }
}
