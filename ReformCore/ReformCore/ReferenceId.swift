//
//  ReferenceId.swift
//  ReformCore
//
//  Created by Laszlo Korte on 26.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

extension ReferenceId : SequenceGeneratable {
    public init(id: Int64) {
        self.init(Int(id))
    }
}