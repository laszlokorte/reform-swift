//
//  Runtime.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

public protocol SubCallId {
    typealias CallType
}

public protocol Runtime {
    static var maxDepth : Int { get }
    
    func subCall<T:SubCallId>(id: T, width: Int, height: Int, makeFit: Bool, dataSet: DataSet, callback: (picture: T.CallType) -> ())
    
    func run(block: (width: Int, height: Int) -> ())
    
    func eval(instruction : Instruction, block: () -> ())

    func scoped(block: () -> ())

    func declare(form : Form)
    
    func get(id: FormIdentifier) -> Form?

    func read(id: FormIdentifier, offset: Int) -> UInt64?

    func write(id: FormIdentifier, offset: Int, value: UInt64)

    func getForms() ->[FormIdentifier]
    
    func reportError(instruction : Instruction, error : RuntimeError)
    
    var shouldStop : Bool { get }
    
    func getDataSet() -> DataSet

}