//
//  PointGrabber.swift
//  ReformTools
//
//  Created by Laszlo Korte on 20.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage


public final class PointGrabber {
    
    private enum State {
        case idle
        case searching(FormIdentifier, SearchingResult)
    }
    
    private enum SearchingResult {
        case none
        case found(position: Vec2d, point: EntityPoint, cycle: Int)
    }

    
    private var state : State = .idle
    let grabUI : GrabUI
    let entityFinder : EntityFinder
    let pointFinder : PointFinder
    let camera: Camera
    let radius : Double
    
    public init(stage : Stage, grabUI : GrabUI, camera: Camera, radius: Double) {
        self.grabUI = grabUI
        self.entityFinder = EntityFinder(stage: stage)
        self.pointFinder = PointFinder(stage: stage)
        self.radius = radius
        self.camera = camera
    }
    
    func refresh() {
        if case .searching(let formId, let result) = state,
            let entity = entityFinder.getEntity(formId) {
            
            let allPoints = entity.points
            
            if case .found(_, let current, _) = result,
                let updated = pointFinder.getUpdatedPoint(current){
                grabUI.state = .active(updated, allPoints)
            } else {
                grabUI.state = .show(allPoints)
            }
            
        } else {
            grabUI.state = .hide
        }
    }
    
    func enable(_ formId: FormIdentifier) {
        if case .searching(formId, _) = state {
        
        } else {
            state = .searching(formId, .none)
        }
        refresh()
    }
    
    func disable() {
        state = .idle
        refresh()
    }
    
    func searchAt(_ position: Vec2d) {
        if case .searching(let formId, let oldResult) = state {
            
            switch oldResult {
            case .found(_, _, let cycle):
                state = .searching(formId, resultFor(formId, position: position, cycle: cycle))
            case .none:
                state = .searching(formId, resultFor(formId, position: position, cycle: 0))
            }
        }
        
        refresh()
    }
    
    func cycle() {
        if case .searching(let formId, .found(let pos, _, let cycle)) = state {
            
            state =  .searching(formId, resultFor(formId, position: pos, cycle: cycle+1))
        }
        
    }
    
    private func resultFor(_ formId : FormIdentifier, position: Vec2d, cycle: Int) -> SearchingResult {
        
        guard let entity = entityFinder.getEntity(formId) else {
            return .none
        }
        let points = entity.points.filter({distance(point: $0.position,point: position) <= radius / camera.zoom})
        
        if points.count > 0 {
            return .found(position: position, point: points[cycle%points.count], cycle: cycle)
        } else {
            return .none
        }
        
    }
    
    var current : EntityPoint? {
        if case .searching(_, .found(_, let point, _)) = state {
            return point
        } else {
            return nil
        }
    }
    
    
}
