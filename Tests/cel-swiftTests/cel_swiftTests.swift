import Testing
import XCTest

@testable import cel_swift

@Test func example() async throws {

    typealias List1 = Cons<Int, Cons<String, Cons<Int, Nil>>>
    print(List1.length)

    let _ = ObjectIdentifier(UInt32.self)
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

final class cel_swiftTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testTypeList() throws {
        typealias List1 = Cons<Int, Cons<String, Cons<Double, Nil>>>
        XCTAssertEqual(List1.length, 3)
    }

    func testRawStack() throws {
        var stack = RawStack()

        // Test with different types to verify alignment handling
        stack.push(consuming: 42)
        stack.push(consuming: "hello")
        stack.push(consuming: 3.14)

        // Pop in reverse order
        XCTAssertEqual(stack.unsafePop() as Double, 3.14)
        XCTAssertEqual(stack.unsafePop() as String, "hello")
        XCTAssertEqual(stack.unsafePop() as Int, 42)

        // Verify stack is empty
        XCTAssert(stack.empty)
    }
}
