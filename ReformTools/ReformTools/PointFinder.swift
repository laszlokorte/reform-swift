//
//  PointFinder.swift
//  ReformTools
//
//  Created by Laszlo Korte on 18.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage
import ReformExpression

enum LocationFilter {
    case Any
    case Near(Vec2d, distance: Double)
}

enum FormFilter {
    case None
    case Any
    case Only(FormIdentifier)
    case Except(FormIdentifier)
}

struct PointQuery {
    let filter: FormFilter
    let pointType: PointType
    let location : LocationFilter
}

struct PointFinder {
    let stage : Stage
    
    func getUpdatedPoint(oldPoint: EntityPoint) -> EntityPoint? {
        for entity in stage.entities
            where entity.id == oldPoint.formId {
                for point in entity.points
                    where point.pointId == oldPoint.pointId {
                        return point
                }
        }
        
        return nil
    }
    
    func getUpdatedPoint(oldPoint: IntersectionSnapPoint) -> IntersectionSnapPoint? {
        for intersection in stage.intersections
            where intersection.point == oldPoint.point {
                return intersection
        }
        
        return nil
    }
    
    func getSnapPoints(query: PointQuery) -> [SnapPoint] {
        var result = [SnapPoint]()
        
        if case FormFilter.None = query.filter {
            return result
        }
        
        if (query.pointType.contains(.Form) || query.pointType.contains(.Glomp))  {
            for entity in stage.entities {
                if case .Except(entity.id) = query.filter {
                    continue
                }
                if case .Only(let id) = query.filter where id != entity.id {
                    continue
                }
                
                if query.pointType.contains(.Form) {
                    for p in entity.points {
                        if case .Near(let loc, let d) = query.location where (loc-p.position).length > d {
                            continue
                        }
                        result.append(p)
                    }
                }
                
                if case .Near(let loc, let d) = query.location where query.pointType.contains(.Glomp) {
                    if let (u, pos) = pointOn(segmentPath: entity.outline, closestTo: loc, maxDistance: d) {

                        result.append(GlompSnapPoint(position: pos, label: "Glomp", point: ReformCore.GlompPoint(formId: entity.id, lerp: Expression.Constant(.DoubleValue(value: u)))))
                    }
                }
            }
        }
        
        if case .Only = query.filter {
            return result
        }
        
        if query.pointType.contains(.Intersection) {
            for intersection in stage.intersections {
                if case .Except(let id) = query.filter where id == intersection.formIdA || id == intersection.formIdB {
                    continue
                }
                if case .Near(let loc, let d) = query.location where (loc-intersection.position).length > d {
                    continue
                }
                result.append(intersection)
            }
        }
        
        return result
    }
}