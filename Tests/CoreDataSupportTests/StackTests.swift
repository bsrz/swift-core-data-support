@testable import CoreDataSupport
import CoreData
import XCTest

class StackTests: XCTestCase {

    private func makeStackWithNewModel() -> Stack {
        Stack(
            storeType: .inMemory(name: name),
            model: NSManagedObjectModel.model(
                inDirectory: "Model",
                named: "Model2",
                in: .module
            )
        )
    }

    /// Using a new model on repeated tests causes a ton of warnings and possibly crashes
    func test0() throws {
        let stack = makeStackWithNewModel()
        let entity = Entity(context: stack.context)
        entity.attribute0 = name
        entity.attribute1 = name
        entity.attribute2 = name

        try stack.save()
    }

    static let model = NSManagedObjectModel.model(
        inDirectory: "Model",
        named: "Model2",
        in: .module
    )

    private func makeStackWithStaticModel() -> Stack {
        Stack(
            storeType: .inMemory(name: name),
            model: Self.model
        )
    }

    /// Using the same model on repeated tests works as expected
    func test1() throws {
        let stack = makeStackWithStaticModel()
        let entity = Entity(context: stack.context)
        entity.attribute0 = name
        entity.attribute1 = name
        entity.attribute2 = name

        try stack.save()
    }
}
