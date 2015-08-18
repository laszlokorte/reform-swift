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
    static func fromEvent(event: NSEvent) -> Modifier {
        var result : Modifier = []
        

        if event.modifierFlags.contains(.ShiftKeyMask) {
            result.unionInPlace(Modifier.Streight)
        }
        
        if event.modifierFlags.contains(.AlternateKeyMask) {
            result.unionInPlace(Modifier.AlternativeAlignment)
        }
        
        if event.modifierFlags.contains(.ControlKeyMask) {
            result.unionInPlace(Modifier.Glomp)
        }

        
        return result
    }
}