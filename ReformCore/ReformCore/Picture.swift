//
//  Picture.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

public struct PictureIdentifier : Hashable, SubCallId {
    public typealias CallType = Picture
    private let id : Int64
    
    public init(_ id : Int64) {
        self.id = id
    }
    
    public var hashValue : Int { return Int(id) }
}

public func ==(lhs: PictureIdentifier, rhs: PictureIdentifier) -> Bool {
    return lhs.id == rhs.id
}

final public class Picture {

    public let identifier : PictureIdentifier
    public var name : String
    public var size : (Double, Double)
    public let procedure  : Procedure
    public let data : Sheet


    public init(identifier : PictureIdentifier, name: String, size: (Double, Double), data: Sheet, procedure : Procedure) {
        self.identifier = identifier
        self.name = name
        self.procedure = procedure
        self.size = size
        self.data = data
    }
    
}