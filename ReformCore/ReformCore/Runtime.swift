//
//  Runtime.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

public protocol RuntimeListener {
    func runtimeBeginEvaluation<R:Runtime>(_ runtime: R, withSize: (Double, Double))
    func runtimeFinishEvaluation<R:Runtime>(_ runtime: R)
    func runtime<R:Runtime>(_ runtime: R, didEval: Evaluatable)
    func runtime<R:Runtime>(_ runtime: R, exitScopeWithForms: [FormIdentifier])
    func runtime<R:Runtime>(_ runtime: R, triggeredError: RuntimeError, on: Evaluatable)
}

public protocol Runtime {
    static var maxDepth : Int { get }
    associatedtype Ev : Evaluatable
    
    var listeners : [RuntimeListener] { get set }
    
    func subCall(_ id: PictureIdentifier, width: Double, height: Double, makeFit: Bool, dataSet: DataSet, callback: @noescape (_ runtime: Self, _ picture: Picture) -> ())
    
    func run(width: Double, height: Double, block: @noescape (Self) -> ())
    
    func eval(_ instruction : Ev, block: @noescape (Self) -> ())

    func scoped( _ block: @noescape (Self) -> ())

    func declare(_ form : Form)
    
    func get(_ id: FormIdentifier) -> Form?

    func read(_ id: FormIdentifier, offset: Int) -> UInt64?

    func write(_ id: FormIdentifier, offset: Int, value: UInt64)

    func getForms() ->[FormIdentifier]
    
    func reportError(_ error : RuntimeError)
    
    var shouldStop : Bool { get }
    
    func getDataSet() -> DataSet

}
