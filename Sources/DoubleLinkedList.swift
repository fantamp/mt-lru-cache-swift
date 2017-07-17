//
//  DoubleLinkedList.swift
//  MtLruCache
//
//  Created by Andrey Mescheryakov on 17/07/2017.
//
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

