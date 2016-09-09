//
//  ProjectWindowController.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

import ReformCore
import ReformExpression
import ReformStage
import ReformMath
import ReformTools

final class ProjectWindowController : NSWindowController {


    lazy var picture : ReformCore.Picture = ReformCore.Picture(identifier : PictureIdentifier(0), name: "Untiled", size: (580,330), data: self.data, procedure: self.procedure)

    lazy var project : Project = Project(pictures: self.picture)
    


    lazy var projectSession : ProjectSession = ProjectSession(project: self.project)


    lazy var pictureSession : PictureSession = PictureSession(projectSession: self.projectSession, picture: self.picture)

    var procedure = Procedure()
    let data = BaseSheet()


    override func windowDidLoad() {
        if let screenFrame = window?.screen?.frame {
            window?.setFrame(NSRect(x:25, y:100, width: screenFrame.width-50, height: screenFrame.height-120), display: true)
            window?.center()
        }

        let rectangleForm = RectangleForm(id: FormIdentifier(98), name: "Rectangle 1")

        let lineForm = LineForm(id: FormIdentifier(99), name: "Line 1")

        let rectangleDestination = RelativeDestination(
            from: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.topLeft.rawValue),
            to: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.center.rawValue)
        )

        let lineDestination = RelativeDestination(
            from: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.topLeft.rawValue),
            to: ForeignFormPoint(formId: rectangleForm.identifier, pointId: RectangleForm.PointId.bottomLeft.rawValue)
        )

        let createInstruction = CreateFormInstruction(form: rectangleForm, destination: rectangleDestination)

        let node1 = InstructionNode(instruction: createInstruction)

        assert(procedure.root.append(child: InstructionNode()))
        assert(procedure.root.append(child: node1))

        let moveInstruction = TranslateInstruction(formId: rectangleForm.identifier, distance: RelativeDistance(
            from: ForeignFormPoint(formId: rectangleForm.identifier, pointId: RectangleForm.PointId.center.rawValue),
            to: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.center.rawValue),
            direction: FreeDirection()))

        let node2 = InstructionNode(instruction: moveInstruction)

        assert(procedure.root.append(child: node2))

        let rotateInstruction = RotateInstruction(
            formId: rectangleForm.identifier,
            angle: ConstantAngle(angle: Angle(percent: 20)),
            fixPoint: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.center.rawValue)
        )

        let node3 = InstructionNode(instruction: rotateInstruction)

        assert(procedure.root.append(child: node3))

        let createLineInstruction = CreateFormInstruction(form: lineForm, destination: lineDestination)
        let node4 = InstructionNode(instruction: createLineInstruction)

        assert(procedure.root.append(child: node4))

        pictureSession.instructionFocus.current = node4

        if let pictureController = contentViewController as? PictureController {

            pictureController.representedObject = pictureSession
        }

        pictureSession.refresh()
    }

    func validate(_ theItem: NSToolbarItem) -> Bool {
        if let _ = ToolbarIdentifier(rawValue: theItem.itemIdentifier) {
            return true
        } else {
            return false
        }
    }


    @IBAction func toolbarButton(_ sender: NSToolbarItem) {
        guard let id = ToolbarIdentifier(rawValue: sender.itemIdentifier) else {
            return
        }

        switch id {
        case .LineToolItem:
            pictureSession.tool = pictureSession.createLineTool
        case .RectangleToolItem:
            pictureSession.tool = pictureSession.createRectTool
        case .CircleToolItem:
            pictureSession.tool = pictureSession.createCircleTool
        case .PieToolItem:
            pictureSession.tool = pictureSession.createPieTool
        case .ArcToolItem:
            pictureSession.tool = pictureSession.createArcTool
        case .TextToolItem:
            pictureSession.tool = pictureSession.createTextTool
        case .PictureToolItem:
            pictureSession.tool = pictureSession.createPictureTool
        case .SelectionToolItem:
            pictureSession.tool = pictureSession.selectionTool
        case .MoveToolItem:
            pictureSession.tool = pictureSession.moveTool
        case .RotateToolItem:
            pictureSession.tool = pictureSession.rotationTool
        case .ScaleToolItem:
            pictureSession.tool = pictureSession.scalingTool
        case .MorphToolItem:
            pictureSession.tool = pictureSession.morphTool
        case .CropToolItem:
            pictureSession.tool = pictureSession.cropTool
        case .PreviewToolItem:
            pictureSession.tool = pictureSession.previewTool

        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {


        if let p = segue.destinationController as? ExportController {
            p.projectSession = projectSession
        }
        
    }

    enum ToolbarIdentifier : String {
        case LineToolItem
        case RectangleToolItem
        case CircleToolItem
        case PieToolItem
        case ArcToolItem
        case TextToolItem
        case PictureToolItem

        case SelectionToolItem
        case MoveToolItem
        case RotateToolItem
        case ScaleToolItem
        case MorphToolItem

        case CropToolItem
        case PreviewToolItem
    }

}

extension ProjectWindowController : NSWindowDelegate {

    func windowDidBecomeMain(_ notification: Notification) {
        contentViewController?.view.needsDisplay = true
    }

    func windowDidResignMain(_ notification: Notification) {
        contentViewController?.view.needsDisplay = true
    }
}
