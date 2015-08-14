//
//  DefaultRuntime.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

class DefaultRuntime : Runtime {
    static let maxDepth : Int = 3
    private var _stopped : Bool
    private var stack = RuntimeStack()
    private var dataSet : DataSet

    var shouldStop : Bool { get { return _stopped } }
    
    init() {
        dataSet = WritableDataSet()
        _stopped = false
    }
    
    func subCall<T:SubCallId>(id: T, width: Int, height: Int, makeFit: Bool, dataSet: DataSet, callback: (picture: T.CallType) -> ()) {
        self.dataSet = dataSet
        
    }
    
    func run(block: (width: Int, height: Int) -> ()) {
        _stopped = false
        defer { _stopped = true }
        stack.clear()
        
        block(width: 100, height: 100)
    }
    
    func eval(instruction : Instruction, block: () -> ()) {
        block()
    }
    
    func scoped(block: () -> ()) {
        stack.pushFrame()
        defer { stack.popFrame() }
        block()
    }
    
    func declare(form : Form) {
        stack.declare(form)
    }
    
    func get(id: FormIdentifier) -> Form? {
        return stack.getForm(id)
    }
    
    func read(id: FormIdentifier, offset: Int) -> UInt64? {
        return stack.getData(id, offset: offset)
    }
    
    func write(id: FormIdentifier, offset: Int, value: UInt64) {
        stack.setData(id, offset: offset, newValue: value)
    }
    
    func getForms() -> [FormIdentifier] {
        return stack.forms
    }
    
    func getDataSet() -> DataSet {
        return dataSet
    }
    
    func reportError(instruction : Instruction, error : RuntimeError) {
    
    }
}