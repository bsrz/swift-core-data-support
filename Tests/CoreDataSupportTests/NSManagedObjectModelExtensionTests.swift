@testable import CoreDataSupport
import CoreData
import XCTest

final class NSManagedObjectModelExtensionTests: XCTestCase {
    func testExtension_whenFetchingAllModels_returnsThemInAscendingOrder() throws {
        let models = NSManagedObjectModel.models(
            inDirectory: "Model",
            in: .module
        )

        XCTAssertEqual(models.count, 3)
        XCTAssertEqual(models[0], NSManagedObjectModel.model(inDirectory: "Model", named: "Model0", in: .module))
        XCTAssertEqual(models[1], NSManagedObjectModel.model(inDirectory: "Model", named: "Model1", in: .module))
        XCTAssertEqual(models[2], NSManagedObjectModel.model(inDirectory: "Model", named: "Model2", in: .module))
    }
}
