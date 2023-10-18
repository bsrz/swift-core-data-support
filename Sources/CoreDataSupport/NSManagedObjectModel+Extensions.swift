import CoreData

extension NSManagedObjectModel {

    /// Looks for all the models (ending in `mom`) inside a given directory (ending in `momd`)
    /// - Parameters:
    ///   - directory: The directory in which to look for models
    ///   - bundle: The bundle containing the models
    /// - Returns: An array of ``URL`` of all available models
    private static func urls(inDirectory directory: String, in bundle: Bundle) -> [URL] {
        bundle
            .urls(
                forResourcesWithExtension: "mom",
                subdirectory: "\(directory).momd"
            )
            .or([])
            .sorted { $0.absoluteString < $1.absoluteString }
    }

    /// Looks for all models inside a given directory
    /// - Parameters:
    ///   - directory: The directory in which to look for models
    ///   - bundle: The bundle containing the models
    /// - Returns: An array of all available ``NSManagedObjectModel``
    static func models(inDirectory directory: String, in bundle: Bundle) -> [NSManagedObjectModel] {
        urls(inDirectory: directory, in: bundle)
            .compactMap(NSManagedObjectModel.init)
    }

    /// Looks for a model with a specific name in a given directory
    /// - Parameters:
    ///   - directory: The directory in which to look for models
    ///   - named: The name of the model to look for
    ///   - bundle: The bundle containing the models
    /// - Returns: The model with a specific name if found, an empty model otherwise
    static func model(inDirectory directory: String, named: String, in bundle: Bundle) -> NSManagedObjectModel {
        let found = urls(inDirectory: directory, in: bundle)
            .filter { $0.lastPathComponent == "\(named).mom" }
            .first
            .flatMap(NSManagedObjectModel.init)

        return found ?? NSManagedObjectModel()
    }
}

extension Optional {
    func or(_ value: Wrapped) -> Wrapped {
        switch self {
        case .none: return value
        case .some(let wrapped): return wrapped
        }
    }
}
