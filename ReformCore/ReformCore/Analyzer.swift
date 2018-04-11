//
//  Analyzer.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

public protocol Analyzer : class {
    func analyze(_ block: () -> ())
    
    func publish(_ instruction: Analyzable, label: String)
    
    func publish(_ instruction: Analyzable, label: String, block: () -> ())
    
    func announceForm(_ form: Form)
    
    func announceDepencency(_ id: PictureIdentifier)
        
    var stringifier : Stringifier { get }
}
