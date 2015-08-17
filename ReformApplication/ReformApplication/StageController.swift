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

class StageController : NSViewController {

    class DebugRuntimeListener : RuntimeListener {
        
        func runtimeBeginEvaluation(runtime: Runtime) {
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
        
        procedure.root.append(CreateFormInstruction(form: rectangleForm, destination: rectangleDestination))
        
        let sheet = BaseSheet()
        let expressionPrinter = ExpressionPrinter(sheet: sheet)
        let analyzer = DefaultAnalyzer(expressionPrinter : expressionPrinter)
        
        let runtime = DefaultRuntime()
        
        runtime.listeners.append(DebugRuntimeListener())
        
        procedure.analyzeWith(analyzer)
        procedure.evaluateWith(runtime)
    }
    
}