//
//  CropGrabber
//  ReformTools
//
//  Created by Laszlo Korte on 29.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage


public final class CropGrabber {

    private enum State {
        case idle
        case searching(SearchingResult)
    }

    private enum SearchingResult {
        case none
        case found(position: Vec2d, point: CropPoint, cycle: Int)
    }


    private var state : State = .idle
    let cropUI : CropUI
    let stage : Stage
    let camera: Camera
    let radius : Double

    public init(stage : Stage, cropUI : CropUI, camera: Camera, radius: Double) {
        self.cropUI = cropUI
        self.stage = stage
        self.radius = radius
        self.camera = camera
    }

    func refresh() {
        if case .searching(let result) = state {

            let allPoints = stage.cropPoints

            if case .found(_, let current, _) = result {
                let updated = CropPoint(position: current.offset.vector * stage.size / 2 + stage.size / 2, offset: current.offset)
                cropUI.state = .active(updated, allPoints)
            } else {
                cropUI.state = .show(allPoints)
            }

        } else {
            cropUI.state = .hide
        }
    }

    func enable() {
        if case .searching(_) = state {

        } else {
            state = .searching(.none)
        }
        refresh()
    }

    func disable() {
        state = .idle
        refresh()
    }

    func searchAt(_ position: Vec2d) {
        if case .searching(let oldResult) = state {

            switch oldResult {
            case .found(_, _, let cycle):
                state = .searching(resultFor(position, cycle: cycle))
            case .none:
                state = .searching(resultFor(position, cycle: 0))
            }
        }

        refresh()
    }

    func cycle() {
        if case .searching(.found(let pos, _, let cycle)) = state {
            state =  .searching(resultFor(pos, cycle: cycle+1))
        }

    }

    private func resultFor(_ position: Vec2d, cycle: Int) -> SearchingResult {

        let points = stage.cropPoints.filter({distance(point:$0.position, point: position) <= radius / camera.zoom})

        if points.count > 0 {
            return .found(position: position, point: points[cycle%points.count], cycle: cycle)
        } else {
            return .none
        }

    }

    var current : CropPoint? {
        if case .searching(.found(_, let point, _)) = state {
            return point
        } else {
            return nil
        }
    }
    
    
}
