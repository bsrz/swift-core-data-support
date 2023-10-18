import CoreData
import Foundation

public enum StoreType {
    case inMemory(name: String)
    case onDisk(url: URL, name: String)

    var name: String {
        switch self {
        case .inMemory(let name):
            return name

        case .onDisk(_, let name):
            return name
        }
    }

    var type: String {
        switch self {
        case .inMemory:
            return NSInMemoryStoreType

        case .onDisk:
            return NSSQLiteStoreType
        }
    }

    var url: URL {
        switch self {
        case .inMemory:
            URL(filePath: "/dev/null")

        case .onDisk(let url, let name):
            URL(filePath: "\(name).sqlite", relativeTo: url)
        }
    }
}
