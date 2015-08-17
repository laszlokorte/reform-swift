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

public protocol RuntimeListener {
    func runtimeBeginEvaluation(runtime: Runtime, withSize: (Int, Int))
    func runtimeFinishEvaluation(runtime: Runtime)
    func runtime(runtime: Runtime, didEval: Evaluatable)
    func runtime(runtime: Runtime, exitScopeWithForms: [FormIdentifier])
    func runtime(runtime: Runtime, triggeredError: RuntimeError, on: Evaluatable)
}

public protocol Runtime : class {
    static var maxDepth : Int { get }
    
    var listeners : [RuntimeListener] { get set }
    
    func subCall<T:SubCallId>(id: T, width: Int, height: Int, makeFit: Bool, dataSet: DataSet, callback: (picture: T.CallType) -> ())
    
    func run(block: (width: Int, height: Int) -> ())
    
    func eval(instruction : Evaluatable, block: () -> ())

    func scoped(block: () -> ())

    func declare(form : Form)
    
    func get(id: FormIdentifier) -> Form?

    func read(id: FormIdentifier, offset: Int) -> UInt64?

    func write(id: FormIdentifier, offset: Int, value: UInt64)

    func getForms() ->[FormIdentifier]
    
    func reportError(error : RuntimeError)
    
    var shouldStop : Bool { get }
    
    func getDataSet() -> DataSet

}