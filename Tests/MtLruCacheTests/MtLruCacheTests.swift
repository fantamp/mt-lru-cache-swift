import XCTest
@testable import MtLruCache


class DllTests: XCTestCase {

    func testEmpty() {
        let dll = DoubleLinkedList()
        XCTAssertNil(dll.head)
        XCTAssertNil(dll.tail)
        XCTAssert(dll.size == 0)
    }


    func testRemoveEmpty() {
        let dll = DoubleLinkedList()
        dll.removeTail()
    }

    func testOneItemAdd() {
        let dll = DoubleLinkedList()
        let node = dll.insertHead(key: "Hello!")
        XCTAssertTrue(dll.head === node)
        XCTAssertTrue(dll.tail === node)
        XCTAssert(dll.size == 1)
    }

    func testOneItemRemoveNode() {
        let dll = DoubleLinkedList()
        let node = dll.insertHead(key: "Hello!")
        dll.remove(node)
        XCTAssertNil(dll.head)
        XCTAssertNil(dll.tail)
        XCTAssert(dll.size == 0)
    }

    func testOneItemRemoveTail() {
        let dll = DoubleLinkedList()
        _ = dll.insertHead(key: "Hello!")
        dll.removeTail()
        XCTAssertNil(dll.head)
        XCTAssertNil(dll.tail)
        XCTAssert(dll.size == 0)
    }

    func testTwoItemsAdd() {
        let dll = DoubleLinkedList()
        let node1 = dll.insertHead(key: "Hello!")
        let node2 = dll.insertHead(key: "Hello!")
        XCTAssertTrue(dll.head === node2)
        XCTAssertTrue(dll.tail === node1)
        XCTAssert(dll.size == 2)
    }

    func testTwoItemsRemoveFirstNode() {
        let dll = DoubleLinkedList()
        let node1 = dll.insertHead(key: "Hello!")
        let node2 = dll.insertHead(key: "Hello!")
        dll.remove(node2)
        XCTAssertTrue(dll.head === node1)
        XCTAssertTrue(dll.tail === node1)
        XCTAssertNil(node1.next)
        XCTAssertNil(node1.prev)
        XCTAssert(dll.size == 1)
    }

    func testTwoItemsRemoveSecondNode() {
        let dll = DoubleLinkedList()
        let node1 = dll.insertHead(key: "Hello!")
        let node2 = dll.insertHead(key: "Hello!")
        dll.remove(node1)
        XCTAssertTrue(dll.head === node2)
        XCTAssertTrue(dll.tail === node2)
        XCTAssertNil(node2.next)
        XCTAssertNil(node2.prev)
        XCTAssert(dll.size == 1)
    }

    func testTwoItemsRemoveTail() {
        let dll = DoubleLinkedList()
        _ = dll.insertHead(key: "Hello!")
        let node2 = dll.insertHead(key: "Hello!")
        dll.removeTail()
        XCTAssertTrue(dll.head === node2)
        XCTAssertTrue(dll.tail === node2)
        XCTAssertNil(node2.next)
        XCTAssertNil(node2.prev)
        XCTAssert(dll.size == 1)
    }

    func testThreeItemsAdd() {
        let dll = DoubleLinkedList()
        let node1 = dll.insertHead(key: "Hello!")
        _ = dll.insertHead(key: "Hello!")
        let node3 = dll.insertHead(key: "Hello!")
        XCTAssertTrue(dll.head === node3)
        XCTAssertTrue(dll.tail === node1)
        XCTAssert(dll.size == 3)
    }

    func testThreeItemsRemoveInside() {
        let dll = DoubleLinkedList()
        let node1 = dll.insertHead(key: "Hello!")
        let node2 = dll.insertHead(key: "Hello!")
        let node3 = dll.insertHead(key: "Hello!")
        dll.remove(node2)
        XCTAssertTrue(dll.head === node3)
        XCTAssertTrue(dll.tail === node1)
        XCTAssert(dll.size == 2)
    }

    func testThreeItemsRemoveHead() {
        let dll = DoubleLinkedList()
        let node1 = dll.insertHead(key: "Hello!")
        let node2 = dll.insertHead(key: "Hello!")
        let node3 = dll.insertHead(key: "Hello!")
        dll.remove(node3)
        XCTAssertTrue(dll.head === node2)
        XCTAssertTrue(dll.tail === node1)
        XCTAssert(dll.size == 2)
    }

    func testThreeItemsRemoveTail() {
        let dll = DoubleLinkedList()
        let node1 = dll.insertHead(key: "Hello!")
        let node2 = dll.insertHead(key: "Hello!")
        let node3 = dll.insertHead(key: "Hello!")
        dll.remove(node1)
        XCTAssertTrue(dll.head === node3)
        XCTAssertTrue(dll.tail === node2)
        XCTAssert(dll.size == 2)
    }

    func testThreeItemsRemoveAllUsingHead() {
        let dll = DoubleLinkedList()
        _ = dll.insertHead(key: "Hello!")
        _ = dll.insertHead(key: "Hello!")
        _ = dll.insertHead(key: "Hello!")
        dll.remove(dll.head!)
        dll.remove(dll.head!)
        dll.remove(dll.head!)
        XCTAssertNil(dll.head)
        XCTAssertNil(dll.tail)
        XCTAssert(dll.size == 0)
    }

    func testThreeItemsRemoveAllUsingTail() {
        let dll = DoubleLinkedList()
        _ = dll.insertHead(key: "Hello!")
        _ = dll.insertHead(key: "Hello!")
        _ = dll.insertHead(key: "Hello!")
        dll.removeTail()
        dll.removeTail()
        dll.removeTail()
        XCTAssertNil(dll.head)
        XCTAssertNil(dll.tail)
        XCTAssert(dll.size == 0)
    }
}


class MyLruCacheTests: XCTestCase {

    class Payload {
        var data: String
        init(_ data: String) {
            self.data = data
        }
    }

    func testEmpty() {
        _ = Cache(capacityLimit: 5)
    }

    func testOneItem() {
        let c = Cache(capacityLimit: 5)
        let d = c.get(key: "key1") { Payload("Hello, world!") }
        XCTAssert((d as! Payload).data == "Hello, world!")
    }

    func testCacheHit() {
        let c = Cache(capacityLimit: 5)
        _ = c.get(key: "key1") { Payload("Hello, world!") }
        var called = false
        let d = c.get(key: "key1") {
            called = true
            return Payload("Hello, world!")
        }
        XCTAssertFalse(called)
        XCTAssert((d as! Payload).data == "Hello, world!")
    }

    func testOverLimit() {
        let c = Cache(capacityLimit: 3)
        _ = c.get(key: "key1") { Payload("Hello, world!1") }
        _ = c.get(key: "key2") { Payload("Hello, world!2") }
        _ = c.get(key: "key3") { Payload("Hello, world!3") }
        _ = c.get(key: "key4") { Payload("Hello, world!4") } // 'key1' here goes out

        var functor2Called = false
        _ = c.get(key: "key1") {
            functor2Called = true
            return Payload("Hello, world!1")
        }
        XCTAssertTrue(functor2Called)
    }
    
}

