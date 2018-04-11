//
//  Evaluatable.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public protocol Evaluatable : class, Analyzable {
    func evaluate<T:Runtime>(_ runtime: T) where T.Ev == Self
}
