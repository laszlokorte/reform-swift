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
    private var _running : Bool
    private var _canceled : Bool

    private var stack = RuntimeStack()
    private var dataSet : DataSet

    private var _depth : Int
    
    private var currentInstructions = [Evaluatable]()

    public var shouldStop : Bool { return _canceled }
    
    public init() {
        dataSet = WritableDataSet()
        _running = false
        _canceled = false
        _depth = 0
    }

    init(depth: Int) {
        dataSet = WritableDataSet()
        _running = false
        _canceled = false
        _depth = depth
    }
    
    public func subCall(_ id: PictureIdentifier, width: Double, height: Double, makeFit: Bool, dataSet: DataSet, callback: (_ runtime: DefaultRuntime, _ picture: Picture) -> ()) {
        if _depth > DefaultRuntime.maxDepth {
            return
        }

        self.dataSet = dataSet
        callback(DefaultRuntime(depth: _depth+1), Picture(identifier : id, name: "Test", size: (width, height), data: BaseSheet(), procedure : Procedure()))
        
    }

    public func stop() {
        _canceled = true
    }
    
    public func run(width: Double, height: Double, block: (DefaultRuntime) -> ()) {
        stack.clear()
        
        listeners.forEach() {
            $0.runtimeBeginEvaluation(self, withSize: (width,height))
        }
        defer {
            if !_canceled {
                listeners.forEach() {
                    $0.runtimeFinishEvaluation(self)
                }
            }
        }

        _canceled = false
        _running = true
        defer {
            _running = false
        }
        
        block(self)
        
    }
    
    public func eval(_ instruction : InstructionNode, block: (DefaultRuntime) -> ()) {
        guard !shouldStop else { return }

        defer {
            if !shouldStop {
                listeners.forEach() {
                    $0.runtime(self, didEval: instruction)
                }
            }
        }
        
        currentInstructions.append(instruction)
        defer { currentInstructions.removeLast() }

        block(self)
    }
    
    public func scoped(_ block: (DefaultRuntime) -> ()) {
        if shouldStop { return }

        stack.pushFrame()
        defer {
            if !shouldStop {
                guard let forms = stack.frames.last?.forms else {
                    fatalError()
                }
                listeners.forEach() {
                    $0.runtime(self, exitScopeWithForms: forms)
                }
            }
            stack.popFrame()

        }
        block(self)
    }
    
    public func declare(_ form : Form) {
        stack.declare(form)
    }
    
    public func get(_ id: FormIdentifier) -> Form? {
        return stack.getForm(id)
    }
    
    public func read(_ id: FormIdentifier, offset: Int) -> UInt64? {
        return stack.getData(id, offset: offset)
    }
    
    public func write(_ id: FormIdentifier, offset: Int, value: UInt64) {
        stack.setData(id, offset: offset, newValue: value)
    }
    
    public func getForms() -> [FormIdentifier] {
        return stack.forms
    }
    
    public func getDataSet() -> DataSet {
        return dataSet
    }
    
    public func reportError(_ error : RuntimeError) {
        listeners.forEach() {
            $0.runtime(self, triggeredError: error, on: currentInstructions.last!)
        }
    }
}
