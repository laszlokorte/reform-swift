//
//  RuntimeStageCollector.swift
//  ReformStage
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore


final public class StageCollector : RuntimeListener {
    
    private let stage : Stage
    private let analyzer : Analyzer
    private let focusFilter : (Evaluatable) -> Bool
    private var collected : Bool = false
    private let buffer = StageBuffer()
    
    public init(stage: Stage, analyzer: Analyzer, focusFilter: (Evaluatable) -> Bool) {
        self.stage = stage
        self.analyzer = analyzer
        self.focusFilter = focusFilter
    }
    
    public func runtimeBeginEvaluation(runtime: Runtime, withSize size: (Int, Int)) {
        collected = false
        buffer.clear()
        buffer.size = Vec2d(x: Double(size.0), y: Double(size.1))
    }
    
    public func runtimeFinishEvaluation(runtime: Runtime) {
        buffer.flush(stage)
    }

    public func runtime(runtime: Runtime, didEval instruction: Evaluatable) {
        guard !collected else { return }
        guard focusFilter(instruction) else { return }
        
        defer { collected = true }
                
        for id in runtime.getForms() {
            guard let entity = entityForRuntimeForm(analyzer, runtime: runtime, formId: id) else { continue }
            
            buffer.entities.append(entity)
            
            guard let drawable = runtime.get(id) as? Drawable where drawable.drawingMode == .Draw else {
                continue
            }
            
            guard let shape = drawable.getShapeFor(runtime) else {
                continue
            }
            
            let idShape = IdentifiedShape(id: id, shape: shape)
            buffer.currentShapes.append(idShape)
        }
    }

    public func runtime(runtime: Runtime, exitScopeWithForms forms: [FormIdentifier]) {
        for id in forms {
            guard let form = runtime.get(id) as? Drawable where form.drawingMode == .Draw else {
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

    public func runtime(runtime: Runtime, triggeredError: RuntimeError, on: Evaluatable) {
        
    }

}


private class StageBuffer {
    
    var size : Vec2d = Vec2d()
    var entities : [Entity] = []

    var currentShapes : [IdentifiedShape] = []
    var finalShapes : [IdentifiedShape] = []
    
    
    func clear() {
        entities.removeAll()
        currentShapes.removeAll()
        finalShapes.removeAll()
        size = Vec2d()
    }
    
    func flush(stage: Stage) {
        stage.size = size
        stage.entities = entities
        stage.currentShapes = currentShapes
        stage.finalShapes = finalShapes
        
        stage.intersections = intersectionsOf(entities)
    }
}

func intersectionsOf(entities: [Entity]) -> [IntersectionSnapPoint] {
    var result = [IntersectionSnapPoint]()
    for (ai, a) in entities.enumerate() {
        for (bi, b) in entities.enumerate()
            where bi>ai && a.id != b.id {
            
            for (index, pos) in intersect(segmentPath: a.outline, and: b.outline).enumerate() {
                result.append(IntersectionSnapPoint(position: pos, label: "Intersection", point: RuntimeIntersectionPoint(formA: a.id, formB: b.id, index: index)))
            }
        }
    }
    
    return result
}