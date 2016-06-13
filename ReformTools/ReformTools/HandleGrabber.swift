//
//  HandleGrabber.swift
//  ReformTools
//
//  Created by Laszlo Korte on 21.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage

public final class HandleGrabber {
    
    private enum State {
        case idle
        case searching(FormIdentifier, SearchingResult)
    }
    
    private enum SearchingResult {
        case none
        case found(position: Vec2d, point: Handle, cycle: Int)
    }
    
    private var state : State = .idle
    let handleUI : HandleUI

    let handleFinder : HandleFinder
    let camera: Camera
    let radius : Double
    
    public init(stage : Stage, handleUI : HandleUI, camera: Camera, radius: Double) {
        self.handleUI = handleUI
        self.handleFinder = HandleFinder(stage: stage)
        self.radius = radius
        self.camera = camera
    }
    
    func refresh() {
        if case .searching(let formId, let result) = state {
        
            let allPoints = handleFinder.getHandles(HandleQuery(filter: .only(.form(formId)), location: .any))
            
            if case .found(_, let current, _) = result,
                let updated = handleFinder.getUpdatedHandle(current){
                    handleUI.state = .active(updated, allPoints)
            } else {
                handleUI.state = .show(allPoints)
            }
            
        } else {
            handleUI.state = .hide
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
        
        let points = handleFinder.getHandles(HandleQuery(filter: .only(.form(formId)), location: .near(position, distance: radius / camera.zoom)))
        
        if points.count > 0 {
            return .found(position: position, point: points[cycle%points.count], cycle: cycle)
        } else {
            return .none
        }
        
    }
    
    var current : Handle? {
        if case .searching(_, .found(_, let handle, _)) = state {
            return handle
        } else {
            return nil
        }
    }
    
    
}
