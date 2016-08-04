//
//  SnapShotCollector.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 26.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformGraphics
import ReformCore

struct InstructionNodeKey : Hashable {
    private let node : InstructionNode

    init(_ instructionNode : InstructionNode) {
        node = instructionNode
    }

    var hashValue : Int {
        return ObjectIdentifier(node).hashValue
    }
}

func ==(lhs: InstructionNodeKey, rhs: InstructionNodeKey) -> Bool {
    return lhs.node === rhs.node
}

final public class SnapshotCollector : RuntimeListener {

    private let maxSize : (Double, Double)
    private var currentSize : (Double, Double) = (0,0)
    private var currentScaled : (Double, Double) = (0,0)
    private(set) var snapshots = [InstructionNodeKey:NSImage]()
    private(set) var instructions = Set<InstructionNodeKey>()
    private(set) var errors = [InstructionNodeKey:RuntimeError]()
    private var errorsBuffer = [InstructionNodeKey:RuntimeError]()
    private(set) var paths = [Path]()

    let drawQueue = DispatchQueue.main


    private var redraw = true

    public init(maxSize : (Double, Double)) {
        self.maxSize = maxSize
    }

    public func runtimeBeginEvaluation<R:Runtime>(_ runtime: R, withSize size: (Double, Double)) {
        paths.removeAll(keepingCapacity: false)
        errorsBuffer.removeAll(keepingCapacity: false)
        instructions.removeAll(keepingCapacity: false)

        currentSize = (Double(size.0), Double(size.1))

        let scale = min(Double(maxSize.0)/Double(currentSize.0),
            Double(maxSize.1)/Double(currentSize.1))

        currentScaled = (
            scale * Double(size.0),
            scale * Double(size.1)
        )

    }

    public func runtimeFinishEvaluation<R:Runtime>(_ runtime: R) {
        swap(&errors, &errorsBuffer)
        self.redraw = false
    }

    public func runtime<R:Runtime>(_ runtime: R, didEval instruction: Evaluatable) {
        guard let instruction = instruction as? InstructionNode else {
            return
        }

        let key = InstructionNodeKey(instruction)

        guard !instructions.contains(key) else {
            return
        }


        instructions.insert(key)

        guard !instruction.isEmpty else {
            return
        }

        guard !instruction.isGroup else {
            return
        }

        guard !snapshots.keys.contains(key) || redraw else {
            return
        }

        let image = imageFor(key)


        if errorsBuffer.keys.contains(key) {
            drawQueue.async { [currentScaled, currentSize] in
                image.lockFocus()
                defer { image.unlockFocus() }
                let size = image.size
                guard let context =  NSGraphicsContext.current()?.cgContext else {
                    return
                }

                context.clear(CGRect(origin: CGPoint(), size: size))

                context.setLineWidth(6)

                context.translateBy(x: (size.width -  CGFloat(currentScaled.0)) / 2,
                    y: (size.height - CGFloat(currentScaled.1)) / 2)
                context.scaleBy(x: CGFloat(currentScaled.0 / currentSize.0), y: CGFloat(currentScaled.1 / currentSize.1))


                context.setFillColor(red: 1, green: 0.7, blue: 0.6, alpha: 1)
                context.setStrokeColor(red: 0.8549, green: 0.1020, blue: 0.0902, alpha: 1.0)
                context.fill(CGRect(x: 0, y: 0, width: currentSize.0, height: currentSize.1))
                context.stroke(CGRect(x: 4, y: 4, width: currentSize.0-8, height: currentSize.1-8))
                
            }
            return
        }

        var currentPaths = [(guide: Bool, current: Bool, proxy: Bool, path: Path)]()


        func pushDrawable(_ drawable: Drawable, formId: FormIdentifier, proxy : Bool) {
            let isCurrent = instruction.target == formId
            let isGuide = drawable.drawingMode == .guide

            guard isCurrent || !isGuide else {
                return
            }

            guard let path = drawable.getPathFor(runtime) else {
                return
            }

            currentPaths.append((guide: isGuide, current: isCurrent, proxy: proxy, path: path))
        }

        for formId in runtime.getForms() {
            let form = runtime.get(formId)

            if let drawable = form as? Drawable {
                pushDrawable(drawable, formId: formId, proxy: false)

            } else if let proxy = form as? ProxyForm {
                if let
                    proxyId = proxy.getFormIdForRuntime(runtime),
                    let drawable = runtime.get(proxyId) as? Drawable {
                    pushDrawable(drawable, formId: formId, proxy: true)
                }
            }
        }


        drawQueue.async { [currentScaled, currentSize, paths, currentPaths] in
            image.lockFocus()
            defer { image.unlockFocus() }
            let size = image.size
            guard let context =  NSGraphicsContext.current()?.cgContext else {
                return
            }

            context.clear(CGRect(origin: CGPoint(), size: size))

            context.setLineWidth(6)

            context.translateBy(x: (size.width -  CGFloat(currentScaled.0)) / 2,
                y: (size.height - CGFloat(currentScaled.1)) / 2)
            context.scaleBy(x: CGFloat(currentScaled.0 / currentSize.0), y: CGFloat(currentScaled.1 / currentSize.1))


            context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
            context.clip(to: CGRect(x: 0, y: 0, width: currentSize.0, height: currentSize.1))

            context.fill(CGRect(x: 0, y: 0, width: currentSize.0, height: currentSize.1))

            context.setFillColor(red: 0.5,green: 0.5,blue: 0.5,alpha: 0.7)
            context.setStrokeColor(red: 0.6,green: 0.6,blue: 0.6,alpha: 1)

            for path in paths {
                path.draw(context)
            }
            context.drawPath(using: CGPathDrawingMode.fillStroke)

            for (isGuide, isCurrent, isProxy, path) in currentPaths {
                if isProxy {
                    context.setFillColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.7)
                    context.setStrokeColor(red: 0.7, green: 0.2, blue: 0.7, alpha: 1)
                } else if isGuide {
                    context.setFillColor(red: 0, green: 0.9, blue: 0.9, alpha: 0.7)
                    context.setStrokeColor(red: 0, green: 0.8, blue: 0.8, alpha: 1)
                } else if isCurrent {
                    context.setFillColor(red: 0.1, green: 0.5, blue: 0.9, alpha: 0.7)
                    context.setStrokeColor(red: 0, green: 0.4, blue: 0.8, alpha: 1)
                } else {
                    context.setFillColor(red: 0.5,green: 0.5,blue: 0.5, alpha: 0.7)
                    context.setStrokeColor(red: 0.4,green: 0.4,blue: 0.4,alpha: 1)
                }

                path.draw(context)
                context.drawPath(using: CGPathDrawingMode.fillStroke)
            }
        }
    }

    func imageFor(_ key: InstructionNodeKey) -> NSImage {
        guard let image = snapshots[key] else {
            let image = NSImage(size: NSSize(width: CGFloat(maxSize.0), height: CGFloat(maxSize.1)))
            snapshots[key] = image
            return image
        }
        return image
    }

    public func runtime<R:Runtime>(_ runtime: R, exitScopeWithForms forms: [FormIdentifier]) {

        for formId in forms {
            guard let form = runtime.get(formId) as? Drawable else {
                continue
            }

            guard form.drawingMode == .draw else {
                continue
            }

            guard let path = form.getPathFor(runtime) else {
                continue
            }

            paths.append(path)
        }

    }

    public func runtime<R:Runtime>(_ runtime: R, triggeredError: RuntimeError, on: Evaluatable) {
        guard let node = on as? InstructionNode else {
            return
        }
        errorsBuffer[InstructionNodeKey(node)] = triggeredError
    }

    func requireRedraw() {
        self.redraw = true
    }

}
