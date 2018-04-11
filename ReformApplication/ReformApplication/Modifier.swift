//
//  Modifier.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 18.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import ReformTools

extension Modifier {
    static func fromEvent(_ event: NSEvent) -> Modifier {
        var result : Modifier = []
        

        if event.modifierFlags.contains(NSEvent.ModifierFlags.shift) {
            result.formUnion(Modifier.Streight)
        }
        
        if event.modifierFlags.contains(NSEvent.ModifierFlags.option) {
            result.formUnion(Modifier.AlternativeAlignment)
        }

        if event.modifierFlags.contains(NSEvent.ModifierFlags.command) {
            result.formUnion(Modifier.Glomp)
        }

        if event.modifierFlags.contains(NSEvent.ModifierFlags.control) {
            result.formUnion(Modifier.Free)
        }

        
        return result
    }
}
