//
//  MtLruCache.swift
//  ResoponsiveViewer
//
//  Created by Andrey Mescheryakov on 26/06/2017.
//  Copyright © 2017 Andrey Mescheryakov. All rights reserved.
//

import Foundation


public class Cache {
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

    public init(capacityLimit: UInt) {
        self.capacityLimit = capacityLimit
    }

    public func get(key: String, f: () -> AnyObject) -> AnyObject {
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

