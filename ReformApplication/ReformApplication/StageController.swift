//
//  StageController.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

import ReformCore
import ReformExpression
import ReformStage

class StageController : NSViewController {
    
    let sheet = BaseSheet()
    lazy var expressionPrinter : ExpressionPrinter = ExpressionPrinter(sheet: self.sheet)
    
    
    lazy var analyzer : DefaultAnalyzer = DefaultAnalyzer(expressionPrinter : self.expressionPrinter)
    let runtime = DefaultRuntime()

    
    var currentInstruction : Instruction? = nil
    let stage = Stage()
    
    lazy var stageCollector : StageCollector = StageCollector(stage: self.stage, analyzer: self.analyzer) {
        guard let c = self.currentInstruction else { return false }
        return c == $0
    }

    class DebugRuntimeListener : RuntimeListener {
        
        func runtimeBeginEvaluation(runtime: Runtime, withSize: (Int, Int)) {
            print("begin evaluation")
        }
        
        func runtimeFinishEvaluation(runtime: Runtime) {
            print("finish evaluation")

        }
        
        
        func runtime(runtime: Runtime, didEval: Instruction) {
            print("eval instruction")

        }
        
        
        func runtime(runtime: Runtime, exitScopeWithForms forms: [FormIdentifier]) {
            print("exit scope")
            
            for id in forms {
                if let form = runtime.get(id) {
                    print("   draw form \(form)")
                }
            }
        }
        
        
        func runtime(runtime: Runtime, triggeredError: RuntimeError, onInstruction: Instruction) {
            print("Error \(triggeredError)")

        }
        
        
    }
    
    override func viewDidLoad() {
        let procedure = Procedure()
        let picture = ReformCore.Picture(identifier : PictureIdentifier(0), name: "Untiled", size: (580,330), procedure: procedure)
        
        let project = Project(pictures: picture)
        
        
        
        let rectangleForm = RectangleForm(id: FormIdentifier(100), name: "Rectangle 1")
        
        let from = ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.TopLeft.rawValue)
        let to = ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.Center.rawValue)
        
        let rectangleDestination = RelativeDestination(
            from: from,
            to: to
        )
        
        let createInstruction = CreateFormInstruction(form: rectangleForm, destination: rectangleDestination)
        procedure.root.append(createInstruction)
        
        currentInstruction = createInstruction
        
        runtime.listeners.append(stageCollector)
        
        procedure.analyzeWith(analyzer)
        procedure.evaluateWith(runtime)
        
        print("Entities:")
        for e in stage.entities {
            print(e)
        }
        
        print("Final Shapes:")
        for s in stage.finalShapes {
            print(s)
        }
    }
    
}