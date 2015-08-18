//
//  HitTester.swift
//  ReformStage
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore

extension Stage {
    public func getSnapPoints(excludeForm: ((FormIdentifier)->Bool)? = nil, excludePoint: ((SnapPoint)->Bool)? = nil) -> [SnapPoint] {
        var result = [SnapPoint]()
        
        for entity in entities {
            if let ef = excludeForm where ef(entity.id) {
                continue
            }
            for p in entity.points {
                if let pf = excludePoint where pf(p) {
                    continue
                }
                result.append(p)
            }
        }
                
        for intersection in intersections {
            if let pf = excludePoint where pf(intersection) {
                continue
            }
            if let ef = excludeForm where ef(intersection.formIdA) || ef(intersection.formIdB) {
                continue
            }
            result.append(intersection)
        }
        
        return result
    }
    
}