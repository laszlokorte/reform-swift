//
//  RuntimeStack.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

final class RuntimeStack {
    var frames = [StackFrame]()
    var data : [UInt64] = []
    var dataSize : Int = 0
    var formMap : [FormIdentifier:Form] = [:]
    var forms : [FormIdentifier] = []
    var offsets : [FormIdentifier:Int] = [:]
    
    func pushFrame() {
        frames.append(StackFrame())
    }
    
    func popFrame() {
        let top = frames.removeLast()
        
        for id in top.forms.reversed() {
            remove(id)
        }
    }
    
    func declare(_ form : Form) {
        if let topFrame = frames.last {
            topFrame.forms.append(form.identifier)
            formMap[form.identifier] = form
            offsets[form.identifier] = dataSize
            dataSize += form.dynamicType.stackSize
            growIfNeeded()
            forms.append(form.identifier)
        }
    }
    
    func growIfNeeded() {
        while data.count < dataSize {
            data.append(0)
        }
    }
    
    func getData(_ id: FormIdentifier, offset: Int) -> UInt64? {
        guard let o = offsets[id] where o + offset < dataSize else {
            return nil
        }
        
        return data[o+offset]
    }
    
    func setData(_ id: FormIdentifier, offset: Int, newValue: UInt64){
        if let o = offsets[id]
        where o + offset < dataSize {
            data[o+offset] = newValue

        }
    }
    
    func getForm(_ id: FormIdentifier) -> Form? {
        return formMap[id]
    }
    
    func clear() {
        frames.removeAll(keepingCapacity: true)
        data.removeAll(keepingCapacity: true)
        dataSize = 0
        formMap.removeAll(keepingCapacity: true)
        forms.removeAll(keepingCapacity: true)
        offsets.removeAll(keepingCapacity: true)
    }
    
    private func remove(_ id: FormIdentifier) {
        if let form = formMap.removeValue(forKey: id) {
            let offset = offsets.removeValue(forKey: id)!
            let size = form.dynamicType.stackSize
            for i in 0..<size
            {
                data[offset + i] = 0
            }
            dataSize -= size
            forms.removeLast() // TODO: fix
        }
    }
}

final class StackFrame {
    var forms : [FormIdentifier] = []
}
