//
//  FormReference.swift
//  ReformCore
//
//  Created by Laszlo Korte on 25.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

struct StaticFormReference : Equatable {
    private let formId : FormIdentifier
    private let offset : Int


    init(formId: FormIdentifier, offset: Int) {
        self.formId = formId
        self.offset = offset
    }

    func getFormFor<R:Runtime>(runtime: R) -> Form? {
        guard let
            id = runtime.read(formId, offset: offset) else {
                return nil
        }

        return runtime.get(FormIdentifier(Int(id)))
    }

    func setFormFor<R:Runtime>(runtime: R, form: Form) {
        runtime.write(formId, offset: offset, value: unsafeBitCast(form.identifier.value, UInt64.self))

    }
}

func ==(lhs: StaticFormReference, rhs: StaticFormReference) -> Bool {
    return lhs.formId == rhs.formId && lhs.offset == rhs.offset
}