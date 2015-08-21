//
//  Start.swift
//  ReformTools
//
//  Created by Laszlo Korte on 19.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformStage

public class PointSnapper {
    
    private enum State {
        case Idle
        case Searching(FormFilter, PointType, SearchingResult)
    }
    
    private enum SearchingResult {
        case None
        case Found(position: Vec2d, point: SnapPoint, cycle: Int)
    }
    
    private var state : State = .Idle
    let snapUI : SnapUI
    let pointFinder : PointFinder
    let distance : Double
    
    public init(stage : Stage, snapUI : SnapUI, radius: Double) {
        self.snapUI = snapUI
        self.pointFinder = PointFinder(stage: stage)
        self.distance = radius
    }

    func refresh() {
        if case .Searching(let filter, let type, let result) = state {
        
            let allPoints = pointFinder.getSnapPoints(PointQuery(filter: filter, pointType: type, location: .Any))
            
            if case .Found(_, let current, _) = result {
                snapUI.state = .Active(current, allPoints)
            } else {
                snapUI.state = .Show(allPoints)
            }
            
        } else {
            snapUI.state = .Hide
        }
    }
    
    func enable(filter: FormFilter, pointType: PointType) {
        if case .Searching(let oldFilter, let oldType, _) = state where filter==oldFilter && pointType == oldType {
            
        } else {
            state = .Searching(filter, pointType, .None)
        }
        refresh()
    }
    
    func disable() {
        state = .Idle
        refresh()
    }
    
    func searchAt(position: Vec2d) {
        if case .Searching(let filter, let type, let oldResult) = state {
            
            switch oldResult {
            case .Found(_, _, let cycle):
                state = .Searching(filter, type, resultFor(filter, pointType: type, position: position, cycle: cycle))
            case .None:
                state = .Searching(filter, type, resultFor(filter, pointType: type, position: position, cycle: 0))
            }
        }
        
        refresh()
    }
    
    func cycle() {
        if case .Searching(let filter, let type, .Found(let pos, _, let cycle)) = state {
            
            state = .Searching(filter, type, resultFor(filter, pointType: type, position: pos, cycle: cycle+1))
        }

    }
    
    private func resultFor(filter: FormFilter, pointType: PointType, position: Vec2d, cycle: Int) -> SearchingResult {
        
        let points = pointFinder.getSnapPoints(PointQuery(filter: filter, pointType: pointType, location: .Near(position, distance: distance)))
        
        if points.count > 0 {
            return .Found(position: position, point: points[cycle%points.count], cycle: cycle)
        } else {
            return .None
        }
    
    }
    
    var current : SnapPoint? {
        if case .Searching(_, _, .Found(_, let point, _)) = state {
            return point
        } else {
            return nil
        }
    }
    
    func getTarget(position: Vec2d) -> Target {
        if let point = current {
            return .Snap(point: point)
        } else {
            return .Free(position: position)
        }
    }

    
}