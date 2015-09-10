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
        case Idle
        case Searching(SearchingResult)
    }

    private enum SearchingResult {
        case None
        case Found(position: Vec2d, point: CropPoint, cycle: Int)
    }


    private var state : State = .Idle
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
        if case .Searching(let result) = state {

            let allPoints = stage.cropPoints

            if case .Found(_, let current, _) = result {
                let updated = CropPoint(position: current.offset.vector * stage.size / 2 + stage.size / 2, offset: current.offset)
                cropUI.state = .Active(updated, allPoints)
            } else {
                cropUI.state = .Show(allPoints)
            }

        } else {
            cropUI.state = .Hide
        }
    }

    func enable() {
        if case .Searching(_) = state {

        } else {
            state = .Searching(.None)
        }
        refresh()
    }

    func disable() {
        state = .Idle
        refresh()
    }

    func searchAt(position: Vec2d) {
        if case .Searching(let oldResult) = state {

            switch oldResult {
            case .Found(_, _, let cycle):
                state = .Searching(resultFor(position, cycle: cycle))
            case .None:
                state = .Searching(resultFor(position, cycle: 0))
            }
        }

        refresh()
    }

    func cycle() {
        if case .Searching(.Found(let pos, _, let cycle)) = state {
            state =  .Searching(resultFor(pos, cycle: cycle+1))
        }

    }

    private func resultFor(position: Vec2d, cycle: Int) -> SearchingResult {

        let points = stage.cropPoints.filter({distance(point:$0.position, point: position) <= radius / camera.zoom})

        if points.count > 0 {
            return .Found(position: position, point: points[cycle%points.count], cycle: cycle)
        } else {
            return .None
        }

    }

    var current : CropPoint? {
        if case .Searching(.Found(_, let point, _)) = state {
            return point
        } else {
            return nil
        }
    }
    
    
}