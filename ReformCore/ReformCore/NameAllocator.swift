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
        taken.removeAll(keepingCapacity: true)
    }

    public func alloc(_ requested: String, numbered: Bool = false) -> String {
        var tested = requested
        var count = 0

        if numbered {
            count += 1
            tested = "\(requested) \(count)"
        }

        while taken.contains(tested) {
            count += 1
            tested = "\(requested) \(count)"
        }

        return tested
    }

    public func announce(_ name: String) {
        taken.insert(name)
    }
}
