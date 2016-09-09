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


public final class CropTool : Tool {
    enum State
    {
        case idle
        case cropping(cropPoint: CropPoint, oldSize: Vec2d, size: Vec2d, offset: Vec2d)
    }

    var state : State = .idle

    let picture : ReformCore.Picture
    let stage : Stage
    let cropGrabber : CropGrabber
    let streightener : Streightener
    let intend : () -> ()

    public init(stage: Stage, cropGrabber: CropGrabber, streightener: Streightener, picture: ReformCore.Picture, callback: @escaping ()->()) {
        self.stage = stage
        self.cropGrabber = cropGrabber
        self.picture = picture

        self.streightener = streightener
        self.intend = callback
    }

    public func setUp() {
        state = .idle
        cropGrabber.enable()
    }

    public func tearDown() {
        cropGrabber.disable()
        state = .idle
    }

    public func refresh() {
        cropGrabber.refresh()
    }

    public func focusChange() {
    }

    public func cancel() {
        switch self.state {
        case .idle:
            state = .idle
        case .cropping(_, let oldSize,_,_):
            picture.size = (oldSize.x, oldSize.y)
            intend()
            state = .idle
        }
    }

    public func process(_ input: Input, atPosition pos: Vec2d, withModifier modifier: Modifier) {

        if modifier.isStreight {
            streightener.enable()
        } else {
            streightener.disable()
        }

        switch state {
        case .idle:
            switch input {
            case .move, .modifierChange:
                cropGrabber.searchAt(pos)
            case .press:
                if let grabbedHandle = cropGrabber.current {
                    state = .cropping(cropPoint: grabbedHandle, oldSize: stage.size, size: stage.size, offset: pos - grabbedHandle.position)
                }
            case .cycle:
                cropGrabber.cycle()
            case .toggle, .release:
                break
            }
        case .cropping(let grabbedHandle, let oldSize, _, let offset):
            switch input {

            case .modifierChange:
                fallthrough
            case .move:
                let handlePosition = (grabbedHandle.offset.vector+1)/2 * stage.size
                let o = grabbedHandle.offset.vector * (pos-offset-handlePosition)
                let newSize = stage.size + o
                let adjustedSize = grabbedHandle.isCorner ? streightener.adjust(newSize, keepRatioOf: oldSize) : newSize

                state = .cropping(cropPoint: grabbedHandle, oldSize: oldSize, size: adjustedSize, offset: offset)
            case .release:
                state = .idle
                process(.move, atPosition: pos, withModifier: modifier)
            case .cycle, .press:
                break
            case .toggle:
                streightener.invert()
            }
        }

        publish()
    }

    private func publish() {
        if case .cropping(_, _, let size, _) = state {
            picture.size = (max(5,size.x), max(5,size.y))
            intend()
        }
    }
}
