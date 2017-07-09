//
//  MtLruCache.swift
//  ResoponsiveViewer
//
//  Created by Andrey Mescheryakov on 26/06/2017.
//  Copyright © 2017 Andrey Mescheryakov. All rights reserved.
//

import Foundation



class DoubleLinkedList {
    class Node {
        var prev: Node? = nil
        var next: Node? = nil
        var key: String

        init(key: String) {
            self.key = key
        }
    }

    var head: Node?
    var tail: Node?
    var size: UInt = 0

    func insertHead(_ n: Node) {
        n.next = head
        n.prev = nil
        if let h = head {
            h.prev = n
        } else {
            tail = n
        }
        head = n
        size += 1
    }

    func insertHead(key: String) -> Node {
        let n = Node(key: key)
        insertHead(n)
        return n
    }

    func moveToHead(_ n: Node) {
        remove(n)
        insertHead(n)
    }

    func removeTail() {
        if let t = tail {
            remove(t)
        }
    }

    func remove(_ n: Node) {
        if let prev = n.prev {
            prev.next = n.next
        }
        if let next = n.next {
            next.prev = n.prev
        }
        // self.tail and self.head are guarnateed to be not nil here:
        // If someone calls remove(n) that means that `n` is in the list. Which
        // means that both self.head and self.tails are not nil
        if n === tail! {
            tail = n.prev
        }
        if n === head! {
            head = n.next
        }
        size -= 1
    }
}

class Cache {
    private class OperationInProgress {
        private var payload: AnyObject? = nil
        private var cond: NSCondition = NSCondition()

        func setPayload(_ p: AnyObject) {
            cond.lock()
            payload = p
            cond.broadcast()
            cond.unlock()
        }

        func waitForPayload() -> AnyObject {
            cond.lock()
            while payload == nil {
                cond.wait()
            }
            return payload!
        }
    }

    private enum ItemState {
        case inProgress(OperationInProgress)
        case ready(AnyObject)
    }


    private class CacheItem {
        let dllNode: DoubleLinkedList.Node
        var state: ItemState

        init(dllNodeWithKey: DoubleLinkedList.Node, operation: OperationInProgress) {
            self.dllNode = dllNodeWithKey
            self.state = .inProgress(operation)
        }
    }

    private var items: [String: CacheItem] = [:]
    private let dll: DoubleLinkedList = DoubleLinkedList()
    private let capacityLimit: UInt
    private var lock: NSLock = NSLock()

    init(capacityLimit: UInt) {
        self.capacityLimit = capacityLimit
    }

    func get(key: String, f: () -> AnyObject) -> AnyObject {
        lock.lock()
        if let item = items[key] {
            dll.moveToHead(item.dllNode)
            switch item.state {
            case .inProgress(let inp):
                lock.unlock()
                return inp.waitForPayload()
            case .ready(let payload):
                lock.unlock()
                return payload
            }
        } else {
            let inp = OperationInProgress()
            let dllNode = dll.insertHead(key: key)
            let item = CacheItem(dllNodeWithKey: dllNode, operation: inp)
            items[key] = item
            while (dll.size > capacityLimit) {
                let keyToRemove = dll.tail!.key
                dll.removeTail()
                items.removeValue(forKey: keyToRemove)
            }
            lock.unlock()

            let payload = f()

            lock.lock()
            item.state = .ready(payload)
            lock.unlock()

            inp.setPayload(payload)  // wakes up all waiting threads
            
            return payload
        }
    }
}

