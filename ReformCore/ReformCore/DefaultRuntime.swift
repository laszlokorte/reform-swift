//
//  DefaultRuntime.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

final public class DefaultRuntime : Runtime {
    public var listeners = [RuntimeListener]()
    
    public static let maxDepth : Int = 3
    private var _stopped : Bool
    private var stack = RuntimeStack()
    private var dataSet : DataSet
    
    private var currentInstructions = [Evaluatable]()

    public var shouldStop : Bool { get { return _stopped } }
    
    public init() {
        dataSet = WritableDataSet()
        _stopped = false
    }
    
    public func subCall<T:SubCallId>(id: T, width: Int, height: Int, makeFit: Bool, dataSet: DataSet, callback: (picture: T.CallType) -> ()) {
        self.dataSet = dataSet
        
    }
    
    public func run(block: (width: Int, height: Int) -> ()) {
        stack.clear()
        
        listeners.forEach() {
            $0.runtimeBeginEvaluation(self, withSize: (100,100))
        }
        defer {
            listeners.forEach() {
                $0.runtimeFinishEvaluation(self)
            }
        }
        
        _stopped = false
        defer {
            _stopped = true
        }
        
        block(width: 100, height: 100)
        
    }
    
    public func eval(instruction : Evaluatable, block: () -> ()) {
        defer {
            listeners.forEach() {
                $0.runtime(self, didEval: instruction)
            }
        }
        
        currentInstructions.append(instruction)
        defer { currentInstructions.removeLast() }
        
        block()
    }
    
    public func scoped(block: () -> ()) {
        stack.pushFrame()
        defer {
            guard let forms = stack.frames.last?.forms else {
                fatalError()
            }
            listeners.forEach() {
                $0.runtime(self, exitScopeWithForms: forms)
            }
            stack.popFrame()
        }
        block()
    }
    
    public func declare(form : Form) {
        stack.declare(form)
    }
    
    public func get(id: FormIdentifier) -> Form? {
        return stack.getForm(id)
    }
    
    public func read(id: FormIdentifier, offset: Int) -> UInt64? {
        return stack.getData(id, offset: offset)
    }
    
    public func write(id: FormIdentifier, offset: Int, value: UInt64) {
        stack.setData(id, offset: offset, newValue: value)
    }
    
    public func getForms() -> [FormIdentifier] {
        return stack.forms
    }
    
    public func getDataSet() -> DataSet {
        return dataSet
    }
    
    public func reportError(error : RuntimeError) {
        listeners.forEach() {
            $0.runtime(self, triggeredError: error, on: currentInstructions.last!)
        }
    }
}