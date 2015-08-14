//
//  Labeled.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public protocol Labeled {
    func getDescription(analyzer: Analyzer) -> String
}