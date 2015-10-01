//
//  Runtime.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

public protocol RuntimeListener {
    func runtimeBeginEvaluation<R:Runtime>(runtime: R, withSize: (Double, Double))
    func runtimeFinishEvaluation<R:Runtime>(runtime: R)
    func runtime<R:Runtime>(runtime: R, didEval: Evaluatable)
    func runtime<R:Runtime>(runtime: R, exitScopeWithForms: [FormIdentifier])
    func runtime<R:Runtime>(runtime: R, triggeredError: RuntimeError, on: Evaluatable)
}

public protocol Runtime {
    static var maxDepth : Int { get }
    typealias Ev : Evaluatable
    
    var listeners : [RuntimeListener] { get set }
    
    func subCall(id: PictureIdentifier, width: Double, height: Double, makeFit: Bool, dataSet: DataSet, @noescape callback: (runtime: Self, picture: Picture) -> ())
    
    func run(width width: Double, height: Double, @noescape block: (Self) -> ())
    
    func eval(instruction : Ev, @noescape block: (Self) -> ())

    func scoped(@noescape block: (Self) -> ())

    func declare(form : Form)
    
    func get(id: FormIdentifier) -> Form?

    func read(id: FormIdentifier, offset: Int) -> UInt64?

    func write(id: FormIdentifier, offset: Int, value: UInt64)

    func getForms() ->[FormIdentifier]
    
    func reportError(error : RuntimeError)
    
    var shouldStop : Bool { get }
    
    func getDataSet() -> DataSet

}