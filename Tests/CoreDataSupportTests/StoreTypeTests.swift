@testable import CoreDataSupport
import CoreData
import XCTest

class StoreTypeTests: XCTestCase {
    func testStoreType_whenInMemory_returnsNameTypeAndURL() {
        let sut: StoreType = .inMemory(name: name)
        XCTAssertEqual(sut.name, name)
        XCTAssertEqual(sut.type, NSInMemoryStoreType)
        XCTAssertEqual(sut.url, URL(filePath: "/dev/null"))
    }

    func testStoreType_whenOnDisk_returnsNameTypeAndURL() {
        let sut: StoreType = .onDisk(url: Bundle.module.bundleURL, name: name)
        XCTAssertEqual(sut.name, name)
        XCTAssertEqual(sut.type, NSSQLiteStoreType)
        XCTAssertEqual(sut.url, URL(filePath: "\(name).sqlite", relativeTo: Bundle.module.bundleURL))
    }
}

