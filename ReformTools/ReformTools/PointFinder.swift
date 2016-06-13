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

enum LocationFilter : Equatable {
    case any
    case near(Vec2d, distance: Double)
    case aabb(ReformMath.AABB2d)
}

extension LocationFilter {
    func matches(_ hitArea: HitArea) -> Bool {
        switch self {
        case .any: return true
        case .near(let point, let distance):
            return hitArea.contains(point, margin: distance)
        case .aabb(let aabb):
            return hitArea.overlaps(aabb)
        }
    }

    func matches(_ point: Vec2d) -> Bool {
        switch self {
        case .any: return true
        case .near(let loc, let d):
            return (point-loc).length <= d
        case .aabb(let aabb):
            return inside(point, aabb: aabb)
        }
    }
}

func ==(lhs: LocationFilter, rhs: LocationFilter) -> Bool {
    switch (lhs, rhs) {
    case (.any, .any):
        return true
    case (.near(let p1, let d1), .near(let p2, let d2)):
        return p1==p2 && d1 == d2
    case (.aabb(let aabb1), .aabb(let aabb2)):
        return aabb1 == aabb2
    default: return false
    }
}

enum FormFilter : Equatable {
    case none
    case any
    case only(SourceIdentifier)
    case except(SourceIdentifier)
}

extension FormFilter {
    func excludes(_ id: SourceIdentifier) -> Bool {
        if case .except(let excl) = self {
            return intersects(excl, id: id)
        }
        if case .only(let only) = self {
            return id.runtimeId != only.runtimeId
        }

        return false
    }
}

func ==(lhs: FormFilter, rhs: FormFilter) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none): return true
    case (.any, .any): return true
    case (.only(let l), .only(let r)): return l==r
    case (.except(let l), .except(let r)): return l==r
    default: return false
    }
}

struct PointQuery : Equatable {
    let filter: FormFilter
    let pointType: PointType
    let location : LocationFilter
}

func ==(lhs: PointQuery, rhs: PointQuery) -> Bool {
    return lhs.filter == rhs.filter && lhs.pointType == rhs.pointType && lhs.location == rhs.location
}

struct PointFinder {
    let stage : Stage
    
    func getUpdatedPoint(_ oldPoint: EntityPoint) -> EntityPoint? {
        for entity in stage.entities
            where entity.id == oldPoint.formId {
                for point in entity.points
                    where point.pointId == oldPoint.pointId {
                        return point
                }
        }
        
        return nil
    }
    
    func getUpdatedPoint(_ oldPoint: IntersectionSnapPoint) -> IntersectionSnapPoint? {
        for intersection in stage.intersections
            where intersection.point == oldPoint.point {
                return intersection
        }
        
        return nil
    }
    
    func getSnapPoints(_ query: PointQuery) -> [SnapPoint] {
        var result = [SnapPoint]()
        
        if case FormFilter.none = query.filter {
            return result
        }
        
        if (query.pointType.contains(.Form) || query.pointType.contains(.Glomp))  {
            for entity in stage.entities {
                if query.filter.excludes(entity.id) {
                    continue
                }

                if query.pointType.contains(.Form) {
                    for p in entity.points {
                        guard query.location.matches(p.position) else {
                            continue
                        }
                        result.append(p)
                    }
                }
                
                if case .near(let loc, let d) = query.location where query.pointType.contains(.Glomp) {
                    if let (u, pos) = pointOn(segmentPath: entity.outline, closestTo: loc, maxDistance: d) {

                        result.append(GlompSnapPoint(position: pos, label: "Glomp", point: ReformCore.GlompPoint(formId: entity.id.runtimeId, lerp: ReformExpression.Expression.constant(.doubleValue(value: u)))))
                    }
                }
            }
        }
        
        if case .only = query.filter {
            return result
        }
        
        if query.pointType.contains(.Intersection) {
            for intersection in stage.intersections {
                if case .except(let id) = query.filter where matches(id, id: intersection.formIdA) || matches(id, id: intersection.formIdB) {
                    continue
                }
                guard query.location.matches(intersection.position) else {
                    continue
                }
                result.append(intersection)
            }
        }

        if query.pointType.contains(.Grid) {
            for x in (0...10) {
                for y in (0...10) {
                    let percent = Vec2d(x:Double(x) / 10, y:Double(y) / 10)
                    let position = percent * stage.size

                    guard query.location.matches(position) else {
                        continue
                    }

                    result.append(GridSnapPoint(position: position, point: GridPoint(percent: percent)))
                }
            }
        }
        
        return result
    }
}
