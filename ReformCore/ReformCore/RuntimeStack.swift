//
//  RuntimeStack.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

class RuntimeStack {
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
        
        for id in top.forms {
            remove(id)
        }
    }
    
    func declare(form : Form) {
        if let topFrame = frames.last {
            topFrame.forms.append(form.identifier)
            offsets[form.identifier] = dataSize
            dataSize += form.dynamicType.stackSize
            forms.append(form.identifier)
        }
    }
    
    func getData(id: FormIdentifier, offset: Int) -> UInt64? {
        guard let o = offsets[id] where o + offset < dataSize else {
            return nil
        }
        
        return data[o+offset]
    }
    
    func setData(id: FormIdentifier, offset: Int, newValue: UInt64){
        if let o = offsets[id] where o + offset < dataSize {
            data[o+offset] = newValue

        }
    }
    
    func getForm(id: FormIdentifier) -> Form? {
        return formMap[id]
    }
    
    func clear() {
        frames.removeAll(keepCapacity: true)
        data.removeAll(keepCapacity: true)
        dataSize = 0
        formMap.removeAll(keepCapacity: true)
        forms.removeAll(keepCapacity: true)
        offsets.removeAll(keepCapacity: true)
    }
    
    private func remove(id: FormIdentifier) {
        if let form = formMap[id] {
            let size = form.dynamicType.stackSize
            for(var i = 1; i <= size; i++)
            {
                data[dataSize - i] = 0;
            }
            dataSize -= size;
            offsets.removeValueForKey(id)
            forms.removeLast() // TODO: fix
        }
    }
}

class StackFrame {
    var forms : [FormIdentifier] = []
}