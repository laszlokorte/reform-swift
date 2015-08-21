//
//  Entity.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformMath

public struct Entity {
    public let formType : Form.Type
    public let id : FormIdentifier
    public let label : String
    public let type : EntityType
    public let hitArea : HitArea
    
    public let handles : [Handle]
    public let points : [EntityPoint]
    public let outline: SegmentPath
}

extension Entity : CustomDebugStringConvertible {
    public var debugDescription : String {
        return "Entity(\(formType), \(id), \(label))"
    }
}


extension Entity : Hashable {
    public var hashValue : Int { return id.hashValue }
}

public func ==(lhs: Entity, rhs: Entity) -> Bool {
    return lhs.id == rhs.id
}

public enum EntityType {
    case Draw
    case Mask
    case Guide
    case Canvas
}

extension EntityType {
    init(drawingMode: DrawingMode) {
        switch drawingMode {
        case .Draw:
            self = .Draw
        case .Guide:
            self = .Guide
        case .Mask:
            self = .Mask
        }
    }
}

public struct EntityPoint : SnapPoint, Equatable {
    public let position : Vec2d
    public let label : String
    public let formId : FormIdentifier
    public let pointId : ExposedPointIdentifier
    
    public var runtimePoint : LabeledPoint {
        return ForeignFormPoint(formId: formId, pointId: pointId)
    }
    
    public func belongsTo(formId: FormIdentifier) -> Bool {
        return formId == self.formId
    }
}


public func ==(lhs: EntityPoint, rhs: EntityPoint) -> Bool {
    return lhs.position == rhs.position && lhs.label == rhs.label && lhs.formId == rhs.formId && lhs.pointId == rhs.pointId
}

func createEntityPoint(analyzer: Analyzer, runtime: Runtime, formId: FormIdentifier, pointId: ExposedPointIdentifier) -> EntityPoint? {
    guard let point = runtime.get(formId)?.getPoints()[pointId],
        let position = point.getPositionFor(runtime) else {
        return nil
    }
    
    return EntityPoint(position: position, label: point.getDescription(analyzer), formId: formId, pointId: pointId)
}


func entityForRuntimeForm(analyzer: Analyzer, runtime: Runtime, formId: FormIdentifier) -> Entity? {

    guard let form = runtime.get(formId) else {
        return nil
    }
    
    switch form {
    case let form as LineForm:
        return entityForRuntimeForm(analyzer, runtime: runtime, line: form)
    case let form as RectangleForm:
        return entityForRuntimeForm(analyzer, runtime: runtime, rectangle: form)
    case let form as CircleForm:
        return entityForRuntimeForm(analyzer, runtime: runtime, circle: form)
    case let form as PieForm:
        return entityForRuntimeForm(analyzer, runtime: runtime, pie: form)
    case let form as ArcForm:
        return entityForRuntimeForm(analyzer, runtime: runtime, arc: form)
    case let form as TextForm:
        return entityForRuntimeForm(analyzer, runtime: runtime, text: form)
    case let form as PictureForm:
        return entityForRuntimeForm(analyzer, runtime: runtime, picture: form)
    case let form as Paper:
        return entityForRuntimeForm(analyzer, runtime: runtime, paper: form)
    default:
        return nil
    }
}

func collectHandles<F:Form where F:Morphable>(analyzer: Analyzer, runtime: Runtime, form: F, pivots: [AnchorIdentifier:(ExposedPointIdentifier, ExposedPointIdentifier,ExposedPointIdentifier, axisName: String?)]) -> [Handle] {
    return form.getAnchors().flatMap() { (anchorId, anchor) -> Handle? in
        guard let pivot = pivots[anchorId],
            let primary = createEntityPoint(analyzer, runtime: runtime, formId: form.identifier, pointId: pivot.1),
            let secondary = createEntityPoint(analyzer, runtime: runtime, formId: form.identifier, pointId: pivot.2),
            let position = anchor.getPositionFor(runtime) else {
                return nil
        }
        
        let axis : ScaleAxis
        
        if let axisname = pivot.axisName {
            axis = .Named(axisname, formId: form.identifier, pivot.0, pivot.1)
        } else {
            axis = .None
        }
        
        return Handle(formId: form.identifier, anchorId: anchorId, pointId: pivot.0, label: anchor.name, position: position, defaultPivot: (primary, secondary), scaleAxis: axis
        )
    }
}

func collectPoints(analyzer: Analyzer, runtime: Runtime, form: Form) -> [EntityPoint] {
        return form.getPoints().flatMap { (pointId, point) -> EntityPoint? in
            guard let position = point.getPositionFor(runtime) else {
                return nil
            }
            
            return EntityPoint(position: position, label: point.getDescription(analyzer), formId: form.identifier, pointId: pointId)
        }
}


func entityForRuntimeForm(analyzer: Analyzer, runtime: Runtime, line form: LineForm) -> Entity? {
    guard let start = form.startAnchor.getPositionFor(runtime),
        let end = form.endAnchor.getPositionFor(runtime) else {
        return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let handles = collectHandles(analyzer, runtime: runtime, form: form, pivots: [
        LineForm.AnchorId.Start.rawValue : (LineForm.PointId.Start.rawValue, LineForm.PointId.End.rawValue, LineForm.PointId.Center.rawValue, nil),
        LineForm.AnchorId.End.rawValue : (LineForm.PointId.End.rawValue, LineForm.PointId.Start.rawValue, LineForm.PointId.Center.rawValue, nil),
    ])
    
    let points = collectPoints(analyzer, runtime: runtime, form: form)
        
    let outline = form.outline.getSegmentsFor(runtime)
        
    let hit = HitArea.Line(a: start, b: end)
    
    return Entity(formType: form.dynamicType, id: form.identifier, label: form.name, type: type, hitArea: hit, handles: handles, points: points, outline: outline)
}

func entityForRuntimeForm(analyzer: Analyzer, runtime: Runtime, rectangle form: RectangleForm) -> Entity? {
    guard let topLeft = form.topLeftAnchor.getPositionFor(runtime),
        let topRight = form.topRightAnchor.getPositionFor(runtime),
        let bottomLeft = form.bottomLeftAnchor.getPositionFor(runtime),
        let bottomRight = form.bottomRightAnchor.getPositionFor(runtime)else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let handles = collectHandles(analyzer, runtime: runtime, form: form, pivots: [
        RectangleForm.AnchorId.TopLeft.rawValue :
            (RectangleForm.PointId.TopLeft.rawValue,
                RectangleForm.PointId.BottomRight.rawValue, RectangleForm.PointId.Center.rawValue, nil),
        
        RectangleForm.AnchorId.TopRight.rawValue :
            (RectangleForm.PointId.TopRight.rawValue,
                RectangleForm.PointId.BottomLeft.rawValue, RectangleForm.PointId.Center.rawValue, nil),
        
        RectangleForm.AnchorId.BottomLeft.rawValue :
            (RectangleForm.PointId.BottomLeft.rawValue,
                RectangleForm.PointId.TopRight.rawValue, RectangleForm.PointId.Center.rawValue, nil),
        
        RectangleForm.AnchorId.BottomRight.rawValue :
            (RectangleForm.PointId.BottomRight.rawValue,
                RectangleForm.PointId.TopLeft.rawValue, RectangleForm.PointId.Center.rawValue, nil),
        
        RectangleForm.AnchorId.Top.rawValue :
            (RectangleForm.PointId.Top.rawValue,
                RectangleForm.PointId.Bottom.rawValue, RectangleForm.PointId.Center.rawValue, "Height"),
        
        RectangleForm.AnchorId.Bottom.rawValue :
            (RectangleForm.PointId.Bottom.rawValue,
                RectangleForm.PointId.Top.rawValue,
                RectangleForm.PointId.Center.rawValue, "Height"),
        
        RectangleForm.AnchorId.Left.rawValue :
            (RectangleForm.PointId.Left.rawValue,
                RectangleForm.PointId.Right.rawValue, RectangleForm.PointId.Center.rawValue, "Width"),
        
        RectangleForm.AnchorId.Right.rawValue :
            (RectangleForm.PointId.Right.rawValue,
                RectangleForm.PointId.Left.rawValue,
                RectangleForm.PointId.Center.rawValue, "Width"),
    ])
    
    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let hit = HitArea.Union(
        HitArea.Triangle(a: topLeft, b: topRight, c: bottomRight),
        HitArea.Triangle(a: topLeft, b: bottomRight, c: bottomLeft)
    )

    
    return Entity(formType: form.dynamicType, id: form.identifier, label: form.name, type: type, hitArea: hit, handles: handles, points: points, outline: outline)
}

func entityForRuntimeForm(analyzer: Analyzer, runtime: Runtime, circle form: CircleForm) -> Entity? {
    guard let center = form.centerPoint.getPositionFor(runtime),
        let radius = form.radius.getLengthFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let handles = collectHandles(analyzer, runtime: runtime, form: form, pivots: [
        CircleForm.AnchorId.Top.rawValue : (
            CircleForm.PointId.Top.rawValue,
            CircleForm.PointId.Center.rawValue,
            CircleForm.PointId.Bottom.rawValue, "Height"),
        
        CircleForm.AnchorId.Bottom.rawValue : (
            CircleForm.PointId.Bottom.rawValue,
            CircleForm.PointId.Center.rawValue,
            CircleForm.PointId.Top.rawValue, "Height"),
        
        CircleForm.AnchorId.Left.rawValue : (
            CircleForm.PointId.Left.rawValue,
            CircleForm.PointId.Center.rawValue,
            CircleForm.PointId.Right.rawValue, "Width"),
        
        CircleForm.AnchorId.Right.rawValue : (
            CircleForm.PointId.Right.rawValue,
            CircleForm.PointId.Center.rawValue,
            CircleForm.PointId.Left.rawValue, "Width"),
        ])
    
    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let hit = HitArea.Circle(center: center, radius: radius)
    
    return Entity(formType: form.dynamicType, id: form.identifier, label: form.name, type: type, hitArea: hit, handles: handles, points: points, outline: outline)
}

func entityForRuntimeForm(analyzer: Analyzer, runtime: Runtime, pie form: PieForm) -> Entity? {
    guard let center = form.centerPoint.getPositionFor(runtime),
        let radius = form.radius.getLengthFor(runtime),
        let lowerAngle = form.angleLowerBound.getAngleFor(runtime),
        let upperAngle = form.angleUpperBound.getAngleFor(runtime)  else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let handles = collectHandles(analyzer, runtime: runtime, form: form, pivots: [
        PieForm.AnchorId.Start.rawValue : (
            PieForm.PointId.Start.rawValue,
            PieForm.PointId.Center.rawValue,
            PieForm.PointId.End.rawValue, nil),
        
        PieForm.AnchorId.End.rawValue : (
            PieForm.PointId.End.rawValue,
            PieForm.PointId.Center.rawValue,
            PieForm.PointId.Start.rawValue, nil),
        
        ])
    
    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let hit = HitArea.Intersection(
        HitArea.Circle(center: center, radius: radius),
        HitArea.Inversion(
            HitArea.Triangle(a: center, b: center+rotate(Vec2d(x: 2*radius, y:0), angle: lowerAngle), c: center+rotate(Vec2d(x: 2*radius, y:0), angle: upperAngle))
        )
    )
    
    return Entity(formType: form.dynamicType, id: form.identifier, label: form.name, type: type, hitArea: hit, handles: handles, points: points, outline: outline)
}


func entityForRuntimeForm(analyzer: Analyzer, runtime: Runtime, arc form: ArcForm) -> Entity? {
    guard let start = form.startPoint.getPositionFor(runtime),
        let end = form.endPoint.getPositionFor(runtime),
        let offset = form.offset.getLengthFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let handles = collectHandles(analyzer, runtime: runtime, form: form, pivots: [
        ArcForm.AnchorId.Start.rawValue : (
            ArcForm.PointId.Start.rawValue,
            ArcForm.PointId.End.rawValue,
            ArcForm.PointId.Center.rawValue, nil),
        
        ArcForm.AnchorId.End.rawValue : (
            ArcForm.PointId.End.rawValue,
            ArcForm.PointId.Start.rawValue,
            ArcForm.PointId.Center.rawValue, nil),
        
        ])
    
    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let center = (start + end) / 2
    let radius = sqrt((start-end).length2 + offset*offset)
    let hit = HitArea.Intersection(
        HitArea.Circle(center: center, radius: radius),
        HitArea.LeftOf(a: start, b: end)
    )
    
    return Entity(formType: form.dynamicType, id: form.identifier, label: form.name, type: type, hitArea: hit, handles: handles, points: points, outline: outline)
}



func entityForRuntimeForm(analyzer: Analyzer, runtime: Runtime, text form: TextForm) -> Entity? {
    guard let start = form.startPoint.getPositionFor(runtime),
        let end = form.endPoint.getPositionFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let handles = collectHandles(analyzer, runtime: runtime, form: form, pivots: [
        TextForm.AnchorId.Start.rawValue : (
            TextForm.PointId.Start.rawValue,
            TextForm.PointId.End.rawValue,
            TextForm.PointId.Center.rawValue, nil),
        
        TextForm.AnchorId.End.rawValue : (
            TextForm.PointId.End.rawValue,
            TextForm.PointId.Start.rawValue,
            TextForm.PointId.Center.rawValue, nil),
        ])
    
    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let hit = HitArea.Line(a: start, b: end)
    
    return Entity(formType: form.dynamicType, id: form.identifier, label: form.name, type: type, hitArea: hit, handles: handles, points: points, outline: outline)
}


func entityForRuntimeForm(analyzer: Analyzer, runtime: Runtime, picture form: PictureForm) -> Entity? {
    
    guard let topLeft = form.topLeftAnchor.getPositionFor(runtime),
        let topRight = form.topRightAnchor.getPositionFor(runtime),
        let bottomLeft = form.bottomLeftAnchor.getPositionFor(runtime),
        let bottomRight = form.bottomRightAnchor.getPositionFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let handles = collectHandles(analyzer, runtime: runtime, form: form, pivots: [
        PictureForm.AnchorId.TopLeft.rawValue : (
                PictureForm.PointId.TopLeft.rawValue,
                PictureForm.PointId.BottomRight.rawValue,
                PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.AnchorId.TopRight.rawValue : (
            PictureForm.PointId.TopRight.rawValue,
            PictureForm.PointId.BottomLeft.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.AnchorId.BottomLeft.rawValue : (
            PictureForm.PointId.BottomLeft.rawValue,
            PictureForm.PointId.TopRight.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.AnchorId.BottomRight.rawValue : (
            PictureForm.PointId.BottomRight.rawValue,
            PictureForm.PointId.TopLeft.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.AnchorId.Top.rawValue : (
            PictureForm.PointId.Top.rawValue,
            PictureForm.PointId.Bottom.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.AnchorId.Bottom.rawValue : (
            PictureForm.PointId.Bottom.rawValue,
            PictureForm.PointId.Top.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.AnchorId.Left.rawValue : (
            PictureForm.PointId.Left.rawValue,
            PictureForm.PointId.Right.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.AnchorId.Right.rawValue : (
            PictureForm.PointId.Right.rawValue,
            PictureForm.PointId.Left.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        ])
    
    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    
    let hit = HitArea.Union(
        HitArea.Triangle(a: topLeft, b: topRight, c: bottomRight),
        HitArea.Triangle(a: topLeft, b: bottomRight, c: bottomLeft)
    )
    
    return Entity(formType: form.dynamicType, id: form.identifier, label: form.name, type: type, hitArea: hit, handles: handles, points: points, outline: outline)
}


func entityForRuntimeForm(analyzer: Analyzer, runtime: Runtime, paper form: Paper) -> Entity? {
    
    let type = EntityType.Canvas
    
    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    
    let hit = HitArea.None
    return Entity(formType: form.dynamicType, id: form.identifier, label: form.name, type: type, hitArea: hit, handles: [], points: points, outline: outline)
}