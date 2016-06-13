//
//  Start.swift
//  ReformTools
//
//  Created by Laszlo Korte on 19.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformStage

public final class PointSnapper {
    
    private enum State {
        case idle
        case searching(FormFilter, PointType, SearchingResult)
    }
    
    private enum SearchingResult {
        case none
        case found(position: Vec2d, point: SnapPoint, cycle: Int)
    }
    
    private var state : State = .idle
    let snapUI : SnapUI
    let pointFinder : PointFinder
    let camera: Camera
    let radius : Double
    
    public init(stage : Stage, snapUI : SnapUI, camera: Camera, radius: Double) {
        self.snapUI = snapUI
        self.pointFinder = PointFinder(stage: stage)
        self.radius = radius
        self.camera = camera
    }

    func refresh() {
        if case .searching(let filter, let type, let result) = state {
        
            let allPoints = pointFinder.getSnapPoints(PointQuery(filter: filter, pointType: type, location: .any))
            
            if case .found(_, let current, _) = result {
                snapUI.state = .active(current, allPoints)
            } else {
                snapUI.state = .show(allPoints)
            }
            
        } else {
            snapUI.state = .hide
        }
    }
    
    func enable(_ filter: FormFilter, pointType: PointType) {
        if case .searching(let oldFilter, let oldType, _) = state where filter==oldFilter && pointType == oldType {
            
        } else {
            state = .searching(filter, pointType, .none)
        }
        refresh()
    }
    
    func disable() {
        state = .idle
        refresh()
    }
    
    func searchAt(_ position: Vec2d) {
        if case .searching(let filter, let type, let oldResult) = state {
            
            switch oldResult {
            case .found(_, _, let cycle):
                state = .searching(filter, type, resultFor(filter, pointType: type, position: position, cycle: cycle))
            case .none:
                state = .searching(filter, type, resultFor(filter, pointType: type, position: position, cycle: 0))
            }
        }
        
        refresh()
    }
    
    func cycle() {
        if case .searching(let filter, let type, .found(let pos, _, let cycle)) = state {
            
            state = .searching(filter, type, resultFor(filter, pointType: type, position: pos, cycle: cycle+1))
        }

    }
    
    private func resultFor(_ filter: FormFilter, pointType: PointType, position: Vec2d, cycle: Int) -> SearchingResult {
        
        let points = pointFinder.getSnapPoints(PointQuery(filter: filter, pointType: pointType, location: .near(position, distance: radius / camera.zoom)))
        
        if points.count > 0 {
            return .found(position: position, point: points[cycle%points.count], cycle: cycle)
        } else {
            return .none
        }
    
    }
    
    var current : SnapPoint? {
        if case .searching(_, _, .found(_, let point, _)) = state {
            return point
        } else {
            return nil
        }
    }
    
    func getTarget(_ position: Vec2d) -> Target {
        if let point = current {
            return .snap(point: point)
        } else {
            return .free(position: position)
        }
    }

    
}
