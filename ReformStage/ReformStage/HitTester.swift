//
//  HitTester.swift
//  ReformStage
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

extension Stage {
    public func getSnapPoints(excludeEntity: ((Entity)->Bool)? = nil, excludePoint: ((SnapPoint)->Bool)? = nil) -> [SnapPoint] {
        var result = [SnapPoint]()
        
        for entity in entities {
            if let ef = excludeEntity where ef(entity) {
                continue
            }
            for p in entity.points {
                if let pf = excludePoint where pf(p) {
                    continue
                }
                result.append(p)
            }
        }
        
        return result
    }
    
}