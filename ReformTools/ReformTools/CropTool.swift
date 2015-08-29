//
//  CropTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage


public class CropTool : Tool {
    enum State
    {
        case Idle
        case Cropping(cropPoint: CropPoint, oldSize: Vec2d, size: Vec2d, offset: Vec2d)
    }

    var state : State = .Idle

    let picture : ReformCore.Picture
    let stage : Stage
    let cropGrabber : CropGrabber
    let streightener : Streightener
    let notifier : () -> ()

    public init(stage: Stage, cropGrabber: CropGrabber, streightener: Streightener, picture: ReformCore.Picture, callback: ()->()) {
        self.stage = stage
        self.cropGrabber = cropGrabber
        self.picture = picture

        self.streightener = streightener
        self.notifier = callback
    }

    public func setUp() {
        state = .Idle
        cropGrabber.enable()
    }

    public func tearDown() {
        cropGrabber.disable()
        state = .Idle
    }

    public func refresh() {
        cropGrabber.refresh()
    }

    public func focusChange() {
    }

    public func cancel() {
        switch self.state {
        case .Idle:
            state = .Idle
        case .Cropping(_, let oldSize,_,_):
            picture.size = (oldSize.x, oldSize.y)
            notifier()
            state = .Idle;
        }
    }

    public func process(input: Input, atPosition pos: Vec2d, withModifier modifier: Modifier) {

        if modifier.isStreight {
            streightener.enable()
        } else {
            streightener.disable()
        }

        switch state {
        case .Idle:
            switch input {
            case .Move, .ModifierChange:
                cropGrabber.searchAt(pos)
            case .Press:
                if let grabbedHandle = cropGrabber.current {
                    state = .Cropping(cropPoint: grabbedHandle, oldSize: stage.size, size: stage.size, offset: pos - grabbedHandle.position)
                }
            case .Cycle:
                cropGrabber.cycle()
            case .Toggle, .Release:
                break
            }
        case .Cropping(let grabbedHandle, let oldSize, _, let offset):
            switch input {

            case .ModifierChange:
                fallthrough
            case .Move:
                let handlePosition = (grabbedHandle.offset.vector+1)/2 * stage.size
                let o = grabbedHandle.offset.vector * (pos-offset-handlePosition)
                let newSize = stage.size + o
                let adjustedSize = grabbedHandle.isCorner ? streightener.adjust(newSize, keepRatioOf: oldSize) : newSize

                state = .Cropping(cropPoint: grabbedHandle, oldSize: oldSize, size: adjustedSize, offset: offset)
            case .Press:
                break
            case .Release:
                state = .Idle
                process(.Move, atPosition: pos, withModifier: modifier)
            case .Cycle:
                break
            case .Toggle:
                streightener.invert()
            }
        }

        publish()
    }

    private func publish() {
        if case .Cropping(_, _, let size, _) = state {


            picture.size = (max(1,size.x), max(1,size.y))
            notifier()
        }
    }
}