//
//  RuntimeStageCollector.swift
//  ReformStage
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore


final public class StageCollector<A:Analyzer> : RuntimeListener {
    
    private let stage : Stage
    private let analyzer : A
    private let focusFilter : (Evaluatable) -> Bool
    private var collected : Bool = false
    private let buffer = StageBuffer()
    
    public init(stage: Stage, analyzer: A, focusFilter: @escaping (Evaluatable) -> Bool) {
        self.stage = stage
        self.analyzer = analyzer
        self.focusFilter = focusFilter
    }
    
    public func runtimeBeginEvaluation<R:Runtime>(_ runtime: R, withSize size: (Double, Double)) {
        collected = false
        buffer.clear()
        buffer.size = Vec2d(x: Double(size.0), y: Double(size.1))
    }
    
    public func runtimeFinishEvaluation<R:Runtime>(_ runtime: R) {
        buffer.flush(stage)
    }

    public func runtime<R:Runtime>(_ runtime: R, didEval instruction: Evaluatable) {
        guard !collected else { return }
        guard focusFilter(instruction) else { return }
        
        defer { collected = true }
                
        for id in runtime.getForms() {
            guard let entity = entityForRuntimeForm(analyzer, runtime: runtime, formId: id) else { continue }
            
            buffer.entities.append(entity)
            
            guard let drawable = runtime.get(id) as? Drawable, drawable.drawingMode == .draw else {
                continue
            }
            
            guard let shape = drawable.getShapeFor(runtime) else {
                continue
            }
            
            let idShape = IdentifiedShape(id: id, shape: shape)
            buffer.currentShapes.append(idShape)
        }
    }

    public func runtime<R:Runtime>(_ runtime: R, exitScopeWithForms forms: [FormIdentifier]) {
        for id in forms {
            guard let form = runtime.get(id) as? Drawable, form.drawingMode == .draw else {
                continue
            }
            
            guard let shape = form.getShapeFor(runtime) else {
                continue
            }
            
            let idShape = IdentifiedShape(id: id, shape: shape)
            
            if !collected {
                buffer.currentShapes.append(idShape)
            }
            
            buffer.finalShapes.append(idShape)
        }
    }

    public func runtime<R:Runtime>(_ runtime: R, triggeredError: RuntimeError, on instruction: Evaluatable) {
        guard !collected else { return }

        guard focusFilter(instruction) else { return }

        buffer.error = triggeredError
    }

    public var recalcIntersections : Bool {
        set(b) { buffer.recalcIntersections = b }
        get { return buffer.recalcIntersections }
    }

}


private class StageBuffer {

    var recalcIntersections = true
    var size : Vec2d = Vec2d()
    var entities : [Entity] = []
    var error : RuntimeError?

    var currentShapes : [IdentifiedShape] = []
    var finalShapes : [IdentifiedShape] = []
    
    
    func clear() {
        entities.removeAll(keepingCapacity: true)
        currentShapes.removeAll(keepingCapacity: true)
        finalShapes.removeAll(keepingCapacity: true)
        size = Vec2d()
        error = nil
    }
    
    func flush(_ stage: Stage) {
        let recalcIntersections = self.recalcIntersections
        DispatchQueue.main.sync {
            [unowned self, stage] in

            stage.size = self.size
            stage.entities = self.entities.lazy.reversed()
            stage.currentShapes = self.currentShapes
            stage.finalShapes = self.finalShapes
            stage.error = self.error

            if recalcIntersections {
                stage.intersections = intersectionsOf(self.entities)
                self.recalcIntersections = false
            }
        }
    }
}

func intersectionsOf(_ entities: [Entity]) -> [IntersectionSnapPoint] {
    
    var result = [IntersectionSnapPoint]()
    for (ai, a) in entities.enumerated() {
        for (bi, b) in entities.enumerated()
            where bi>ai && a.id != b.id {
            
            for (index, pos) in intersect(segmentPath: a.outline, and: b.outline).enumerated() {
                result.append(IntersectionSnapPoint(position: pos, label: "Intersection", point: RuntimeIntersectionPoint(formA: a.id.runtimeId, formB: b.id.runtimeId, index: index)))
            }
        }
    }
    
    return result
}
