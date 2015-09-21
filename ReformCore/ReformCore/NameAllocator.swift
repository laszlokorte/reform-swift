//
//  NameAllocator.swift
//  ReformCore
//
//  Created by Laszlo Korte on 21.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public class NameAllocator {
    private var taken = Set<String>()

    public init() {
    }

    public func reset() {
        taken.removeAll(keepCapacity: true)
    }

    public func alloc(requested: String, numbered: Bool = false) -> String {
        var tested = requested
        var count = 0

        if numbered {
            count++
            tested = "\(requested) \(count)"
        }

        while taken.contains(tested) {
            count++
            tested = "\(requested) \(count)"
        }

        return tested
    }

    public func announce(name: String) {
        taken.insert(name)
    }
}