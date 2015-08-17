//
//  Picture.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

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
    let identifier : PictureIdentifier
    var name : String
    var size : (Int, Int)
    let procedure  : Procedure
    
    public init(identifier : PictureIdentifier, name: String, size: (Int, Int), procedure : Procedure) {
        self.identifier = identifier
        self.name = name
        self.procedure = procedure
        self.size = size
    }
    
}