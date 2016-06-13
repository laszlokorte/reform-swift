//
//  Entity.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformMath

public enum SourceIdentifier : Equatable {
    case form(FormIdentifier)
    case proxy(proxy: FormIdentifier, instance: FormIdentifier)

    public init(form id: FormIdentifier) {
        self = form(id)
    }

    public init(proxy: FormIdentifier, id: FormIdentifier) {
        self = .proxy(proxy: proxy, instance: id)
    }

    public var runtimeId : FormIdentifier {
        switch self {
        case form(let id):
            return id
        case .proxy(let id, _):
            return id
        }
    }
}

extension SourceIdentifier : Hashable {
    public var hashValue : Int {
        switch self {
        case form(let id):
            return id.hashValue
        case .proxy(let p, let i):
            return p.hashValue + 13 * i.hashValue
        }
    }
}

public func matches(_ lhs: SourceIdentifier, id rhs: FormIdentifier) -> Bool {
    switch lhs {
    case .form(let id):
        return id == rhs
    case .proxy(let proxyId, let id):
        return proxyId == rhs
            || id == rhs
    }
}

public func intersects(_ lhs: SourceIdentifier, id rhs: SourceIdentifier) -> Bool {
    switch lhs {
    case .form(let id):
        switch rhs {
        case .form(let a):
            return id == a
        case .proxy(let a, let b):
            return id == a || id == b
        }
    case .proxy(let proxyId, let id):
        switch rhs {
        case .form(let a):
            return id == a || proxyId == a
        case .proxy(let a, let b):
            return id == a
                || id == b
                || proxyId == a
                || proxyId == b
        }
    }
}

public func ==(lhs: SourceIdentifier, rhs: SourceIdentifier) -> Bool {
    switch (lhs, rhs) {
    case (.form(let l), .form(let r)):
        return l == r
    case (.proxy(let p1, let i1), .proxy(let p2, let i2)):
        return p1 == p2 && i1 == i2
    default:
        return false
    }
}

public struct Entity {
    public let formType : ReformCore.Form.Type
    public let id : SourceIdentifier
    public let label : String
    public let type : EntityType
    public let hitArea : HitArea
    
    public let handles : [Handle]
    public let affineHandles : [AffineHandle]
    public let points : [EntityPoint]
    public let outline: SegmentPath

    init(formType: ReformCore.Form.Type, id: SourceIdentifier, label: String, type: EntityType, hitArea: HitArea, handles: [Handle], affineHandles: [AffineHandle], points: [EntityPoint], outline: SegmentPath) {
        self.formType = formType
        self.id = id
        self.label = label
        self.type = type
        self.hitArea = hitArea
        self.handles = handles
        self.affineHandles = affineHandles
        self.points = points
        self.outline = outline
    }
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
    case draw
    case mask
    case guide
    case canvas
    case proxy
}

extension EntityType {
    init(drawingMode: DrawingMode) {
        switch drawingMode {
        case .draw:
            self = .draw
        case .guide:
            self = .guide
        case .mask:
            self = .mask
        }
    }
}

public struct EntityPoint : SnapPoint, Equatable {
    public let position : Vec2d
    public let label : String
    public let formId : SourceIdentifier
    public let pointId : ExposedPointIdentifier
    
    public var runtimePoint : LabeledPoint {
        return ForeignFormPoint(formId: formId.runtimeId, pointId: pointId)
    }
    
    public func belongsTo(_ formId: FormIdentifier) -> Bool {
        return self.formId.runtimeId == formId
    }
}


public func ==(lhs: EntityPoint, rhs: EntityPoint) -> Bool {
    return lhs.position == rhs.position && lhs.label == rhs.label && lhs.formId == rhs.formId && lhs.pointId == rhs.pointId
}

func createEntityPoint<R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, formId: FormIdentifier, pointId: ExposedPointIdentifier, sourceId: SourceIdentifier? = nil) -> EntityPoint? {
    guard let
        point = runtime.get(formId)?.getPoints()[pointId],
        position = point.getPositionFor(runtime) else {
        return nil
    }
    
    return EntityPoint(position: position, label: point.getDescription(analyzer.stringifier), formId: sourceId ?? .form(formId), pointId: pointId)
}


func entityForRuntimeForm<R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, formId: FormIdentifier) -> Entity? {

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

    case let form as ProxyForm:
        return entityForRuntimeForm(analyzer, runtime: runtime, paper: form)
    default:
        return nil
    }
}

func collectAffineHandles<F:ReformCore.Form,  R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, form: F, pivots: [ExposedPointIdentifier:(ExposedPointIdentifier,ExposedPointIdentifier, axisName: String?)], sourceId: SourceIdentifier? = nil) -> [AffineHandle] {
    return form.getPoints().flatMap() { (pointId, point) -> AffineHandle? in
        guard let
            pivot = pivots[pointId],
            primary = createEntityPoint(analyzer, runtime: runtime, formId: form.identifier, pointId: pivot.0, sourceId: sourceId),
            secondary = createEntityPoint(analyzer, runtime: runtime, formId: form.identifier, pointId: pivot.1, sourceId: sourceId),
            position = point.getPositionFor(runtime) else {
                return nil
        }

        let axis : ScaleAxis

        if let axisname = pivot.axisName {
            axis = .named(axisname, formId: form.identifier, pivot.0, pivot.1)
        } else {
            axis = .none
        }

        return AffineHandle(formId: .form(form.identifier), pointId: pointId, label: point.getDescription(analyzer.stringifier), position: position, defaultPivot: (primary, secondary), scaleAxis: axis
        )
    }
}

func collectHandles<F:ReformCore.Form,  R:Runtime, A:Analyzer where F:Morphable>(_ analyzer: A, runtime: R, form: F, points: [AnchorIdentifier: ExposedPointIdentifier]) -> [Handle] {
    return form.getAnchors().flatMap() { (anchorId, anchor) -> Handle? in
        guard let
            position = anchor.getPositionFor(runtime),
            pointId = points[anchorId] else {
                return nil
        }

        return Handle(formId: .form(form.identifier), anchorId: anchorId, pointId: pointId, label: anchor.name, position: position)
    }
}

func collectPoints<R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, form: ReformCore.Form, sourceId: SourceIdentifier? = nil) -> [EntityPoint] {
        return form.getPoints().flatMap { (pointId, point) -> EntityPoint? in
            guard let position = point.getPositionFor(runtime) else {
                return nil
            }
            
            return EntityPoint(position: position, label: point.getDescription(analyzer.stringifier), formId: sourceId ?? .form(form.identifier), pointId: pointId)
        }
}


func entityForRuntimeForm<R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, line form: LineForm) -> Entity? {
    guard let
        start = form.startAnchor.getPositionFor(runtime),
        end = form.endAnchor.getPositionFor(runtime) else {
        return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        LineForm.PointId.start.rawValue : (LineForm.PointId.end.rawValue, LineForm.PointId.center.rawValue, nil),
        LineForm.PointId.end.rawValue : (LineForm.PointId.start.rawValue, LineForm.PointId.center.rawValue, nil),
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
        LineForm.AnchorId.start.rawValue : LineForm.PointId.start.rawValue,
        LineForm.AnchorId.end.rawValue : LineForm.PointId.end.rawValue,
    ])
    
    let points = collectPoints(analyzer, runtime: runtime, form: form)
        
    let outline = form.outline.getSegmentsFor(runtime)
        
    let hit = HitArea.line(LineSegment2d(from: start, to: end))
    
    return Entity(formType: form.dynamicType, id: .form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles, points: points, outline: outline)
}

func entityForRuntimeForm<R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, rectangle form: RectangleForm) -> Entity? {
    guard let
        topLeft = form.topLeftAnchor.getPositionFor(runtime),
        topRight = form.topRightAnchor.getPositionFor(runtime),
        bottomLeft = form.bottomLeftAnchor.getPositionFor(runtime),
        bottomRight = form.bottomRightAnchor.getPositionFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        RectangleForm.PointId.topLeft.rawValue :
            (RectangleForm.PointId.bottomRight.rawValue, RectangleForm.PointId.center.rawValue, nil),
        
        RectangleForm.PointId.topRight.rawValue :
            (RectangleForm.PointId.bottomLeft.rawValue, RectangleForm.PointId.center.rawValue, nil),
        
        RectangleForm.PointId.bottomLeft.rawValue :
            (RectangleForm.PointId.topRight.rawValue, RectangleForm.PointId.center.rawValue, nil),
        
        RectangleForm.PointId.bottomRight.rawValue :
            (RectangleForm.PointId.topLeft.rawValue, RectangleForm.PointId.center.rawValue, nil),
        
        RectangleForm.PointId.top.rawValue :
            (RectangleForm.PointId.bottom.rawValue, RectangleForm.PointId.center.rawValue, "Height"),
        
        RectangleForm.PointId.bottom.rawValue :
            (RectangleForm.PointId.top.rawValue,
                RectangleForm.PointId.center.rawValue, "Height"),
        
        RectangleForm.PointId.left.rawValue :
            (RectangleForm.PointId.right.rawValue, RectangleForm.PointId.center.rawValue, "Width"),
        
        RectangleForm.PointId.right.rawValue :
            (RectangleForm.PointId.left.rawValue,
                RectangleForm.PointId.center.rawValue, "Width"),
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
        RectangleForm.AnchorId.topLeft.rawValue :
            RectangleForm.PointId.topLeft.rawValue,

        RectangleForm.AnchorId.topRight.rawValue :
            RectangleForm.PointId.topRight.rawValue,

        RectangleForm.AnchorId.bottomLeft.rawValue :
            RectangleForm.PointId.bottomLeft.rawValue,

        RectangleForm.AnchorId.bottomRight.rawValue :
            RectangleForm.PointId.bottomRight.rawValue,

        RectangleForm.AnchorId.top.rawValue :
            RectangleForm.PointId.top.rawValue,

        RectangleForm.AnchorId.bottom.rawValue :
            RectangleForm.PointId.bottom.rawValue,

        RectangleForm.AnchorId.left.rawValue :
            RectangleForm.PointId.left.rawValue,

        RectangleForm.AnchorId.right.rawValue :
            RectangleForm.PointId.right.rawValue,
        ])

    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let hit = HitArea.union(
        HitArea.triangle(Triangle2d(a: topLeft, b: topRight, c: bottomRight)),
        HitArea.triangle(Triangle2d(a: topLeft, b: bottomRight, c: bottomLeft))
    )
    
    return Entity(formType: form.dynamicType, id: .form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles, points: points, outline: outline)
}

func entityForRuntimeForm<R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, circle form: CircleForm) -> Entity? {
    guard let
        center = form.centerPoint.getPositionFor(runtime),
        radius = form.radius.getLengthFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        CircleForm.PointId.top.rawValue : (
            CircleForm.PointId.center.rawValue,
            CircleForm.PointId.bottom.rawValue, nil),
        
        CircleForm.PointId.bottom.rawValue : (
            CircleForm.PointId.center.rawValue,
            CircleForm.PointId.top.rawValue, nil),
        
        CircleForm.PointId.left.rawValue : (
            CircleForm.PointId.center.rawValue,
            CircleForm.PointId.right.rawValue, nil),
        
        CircleForm.PointId.right.rawValue : (
            CircleForm.PointId.center.rawValue,
            CircleForm.PointId.left.rawValue, nil),
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
        CircleForm.AnchorId.top.rawValue :
            CircleForm.PointId.top.rawValue,

        CircleForm.AnchorId.bottom.rawValue :
            CircleForm.PointId.bottom.rawValue,

        CircleForm.AnchorId.left.rawValue :
            CircleForm.PointId.left.rawValue,

        CircleForm.AnchorId.right.rawValue :
            CircleForm.PointId.right.rawValue,
        ])
    
    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let hit = HitArea.circle(Circle2d(center: center, radius: radius))
    
    return Entity(formType: form.dynamicType, id: .form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles,  points: points, outline: outline)
}

func entityForRuntimeForm<R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, pie form: PieForm) -> Entity? {
    guard let
        center = form.centerPoint.getPositionFor(runtime),
        radius = form.radius.getLengthFor(runtime),
        lowerAngle = form.angleLowerBound.getAngleFor(runtime),
        upperAngle = form.angleUpperBound.getAngleFor(runtime)
    else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        PieForm.PointId.start.rawValue : (
            PieForm.PointId.center.rawValue,
            PieForm.PointId.end.rawValue, nil),
        
        PieForm.PointId.end.rawValue : (
            PieForm.PointId.center.rawValue,
            PieForm.PointId.start.rawValue, nil),
        
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
        PieForm.AnchorId.start.rawValue :
            PieForm.PointId.start.rawValue,

        PieForm.AnchorId.end.rawValue :
            PieForm.PointId.end.rawValue,

        ])

    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let hit = HitArea.intersection(
        HitArea.arc(Arc2d(center: center, radius: radius, range: AngleRange(start: lowerAngle, end: upperAngle))),
        HitArea.sector(center: center, range: AngleRange(start: lowerAngle, end: upperAngle))
    )
    
    return Entity(formType: form.dynamicType, id: .form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles,  points: points, outline: outline)
}


func entityForRuntimeForm<R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, arc form: ArcForm) -> Entity? {
    guard let
        start = form.startPoint.getPositionFor(runtime),
        end = form.endPoint.getPositionFor(runtime),
        center = form.centerPoint.getPositionFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        ArcForm.PointId.start.rawValue : (
            ArcForm.PointId.end.rawValue,
            ArcForm.PointId.center.rawValue, nil),
        
        ArcForm.PointId.end.rawValue : (
            ArcForm.PointId.start.rawValue,
            ArcForm.PointId.center.rawValue, nil),
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
        ArcForm.AnchorId.start.rawValue : ArcForm.PointId.start.rawValue,

        ArcForm.AnchorId.end.rawValue : ArcForm.PointId.end.rawValue,

        ArcForm.AnchorId.center.rawValue : ArcForm.PointId.center.rawValue,
    ])

    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let radius = (start - center).length

    let hit : HitArea

    if let line = Line2d(from: end, direction: end-start) {
        hit = HitArea.intersection(
            HitArea.circle(Circle2d(center: center, radius: radius)),
            HitArea.leftOf(line)
        )
    } else {
        hit = HitArea.circle(Circle2d(center: center, radius: radius))
    }

    
    return Entity(formType: form.dynamicType, id: .form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles,  points: points, outline: outline)
}



func entityForRuntimeForm<R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, text form: TextForm) -> Entity? {
    guard let
        start = form.startPoint.getPositionFor(runtime),
        end = form.endPoint.getPositionFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        TextForm.PointId.start.rawValue : (
            TextForm.PointId.end.rawValue,
            TextForm.PointId.bottom.rawValue, nil),
        
        TextForm.PointId.end.rawValue : (
            TextForm.PointId.start.rawValue,
            TextForm.PointId.bottom.rawValue, nil),
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
            TextForm.AnchorId.start.rawValue :
            TextForm.PointId.start.rawValue,

        TextForm.AnchorId.end.rawValue :
            TextForm.PointId.end.rawValue,

            TextForm.AnchorId.top.rawValue :
            TextForm.PointId.top.rawValue,
        ])

    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let hit = HitArea.line(LineSegment2d(from: start, to: end))
    
    return Entity(formType: form.dynamicType, id: .form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles,  points: points, outline: outline)
}


func entityForRuntimeForm<R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, picture form: PictureForm) -> Entity? {
    
    guard let
        topLeft = form.topLeftAnchor.getPositionFor(runtime),
        topRight = form.topRightAnchor.getPositionFor(runtime),
        bottomLeft = form.bottomLeftAnchor.getPositionFor(runtime),
        bottomRight = form.bottomRightAnchor.getPositionFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        PictureForm.PointId.topLeft.rawValue : (
            PictureForm.PointId.bottomRight.rawValue,
            PictureForm.PointId.center.rawValue, nil),
        
        PictureForm.PointId.topRight.rawValue : (
            PictureForm.PointId.bottomLeft.rawValue,
            PictureForm.PointId.center.rawValue, nil),
        
        PictureForm.PointId.bottomLeft.rawValue : (
            PictureForm.PointId.topRight.rawValue,
            PictureForm.PointId.center.rawValue, nil),
        
        PictureForm.PointId.bottomRight.rawValue : (
            PictureForm.PointId.topLeft.rawValue,
            PictureForm.PointId.center.rawValue, nil),
        
        PictureForm.PointId.top.rawValue : (
            PictureForm.PointId.bottom.rawValue,
            PictureForm.PointId.center.rawValue, nil),
        
        PictureForm.PointId.bottom.rawValue : (
            PictureForm.PointId.top.rawValue,
            PictureForm.PointId.center.rawValue, nil),
        
        PictureForm.PointId.left.rawValue : (
            PictureForm.PointId.right.rawValue,
            PictureForm.PointId.center.rawValue, nil),
        
        PictureForm.PointId.right.rawValue : (
            PictureForm.PointId.left.rawValue,
            PictureForm.PointId.center.rawValue, nil),
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
        PictureForm.AnchorId.topLeft.rawValue :
            PictureForm.PointId.topLeft.rawValue,

        PictureForm.AnchorId.topRight.rawValue :
            PictureForm.PointId.topRight.rawValue,

        PictureForm.AnchorId.bottomLeft.rawValue :
            PictureForm.PointId.bottomLeft.rawValue,

        PictureForm.AnchorId.bottomRight.rawValue :
            PictureForm.PointId.bottomRight.rawValue,

        PictureForm.AnchorId.top.rawValue :
            PictureForm.PointId.top.rawValue,

        PictureForm.AnchorId.bottom.rawValue :
            PictureForm.PointId.bottom.rawValue,

        PictureForm.AnchorId.left.rawValue :
            PictureForm.PointId.left.rawValue,

        PictureForm.AnchorId.right.rawValue :
            PictureForm.PointId.right.rawValue,
    ])

    

    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    
    let hit = HitArea.union(
        HitArea.triangle(Triangle2d(a: topLeft, b: topRight, c: bottomRight)),
        HitArea.triangle(Triangle2d(a: topLeft, b: bottomRight, c: bottomLeft))
    )
    
    return Entity(formType: form.dynamicType, id: .form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles, points: points, outline: outline)
}


func entityForRuntimeForm<R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, paper form: ProxyForm) -> Entity? {
    let type = EntityType.proxy

    guard let instanceId = form.getFormIdForRuntime(runtime) else {
        return nil
    }

    guard let aabb = form.outline.getAABBFor(runtime) else {
        return nil
    }


    let points = collectPoints(analyzer, runtime: runtime, form: form, sourceId: .proxy(proxy: form.identifier, instance: instanceId))

    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [

        ProxyForm.PointId.topLeft.rawValue : (
            ProxyForm.PointId.bottomRight.rawValue,
            ProxyForm.PointId.center.rawValue, nil),

        ProxyForm.PointId.topRight.rawValue : (
            ProxyForm.PointId.bottomLeft.rawValue,
            ProxyForm.PointId.center.rawValue, nil),

        ProxyForm.PointId.bottomLeft.rawValue : (
            ProxyForm.PointId.topRight.rawValue,
            ProxyForm.PointId.center.rawValue, nil),

        ProxyForm.PointId.bottomRight.rawValue : (
            ProxyForm.PointId.topLeft.rawValue,
            ProxyForm.PointId.center.rawValue, nil),

        ProxyForm.PointId.top.rawValue : (
            ProxyForm.PointId.bottom.rawValue,
            ProxyForm.PointId.center.rawValue, nil),

        ProxyForm.PointId.bottom.rawValue : (
            ProxyForm.PointId.top.rawValue,
            ProxyForm.PointId.center.rawValue, nil),

        ProxyForm.PointId.left.rawValue : (
            ProxyForm.PointId.right.rawValue,
            ProxyForm.PointId.center.rawValue, nil),

        ProxyForm.PointId.right.rawValue : (
            ProxyForm.PointId.left.rawValue,
            ProxyForm.PointId.center.rawValue, nil),
        ], sourceId: .proxy(proxy: form.identifier, instance: instanceId))

    let outline = form.outline.getSegmentsFor(runtime)

    let hit = HitArea.union(
        HitArea.triangle(Triangle2d(a: aabb.min, b: aabb.xMinYMax, c: aabb.max)),
        HitArea.triangle(Triangle2d(a: aabb.max, b: aabb.xMaxYMin, c: aabb.min))
    )

    return Entity(formType: form.dynamicType, id: .proxy(proxy: form.identifier, instance: instanceId), label: form.name, type: type, hitArea: hit, handles: [],affineHandles: affineHandles,  points: points, outline: outline)
}


func entityForRuntimeForm<R:Runtime, A:Analyzer>(_ analyzer: A, runtime: R, paper form: Paper) -> Entity? {

    let type = EntityType.canvas

    let points = collectPoints(analyzer, runtime: runtime, form: form)

    let outline = form.outline.getSegmentsFor(runtime)

    let hit = HitArea.none
    return Entity(formType: form.dynamicType, id: .form(form.identifier), label: form.name, type: type, hitArea: hit, handles: [],affineHandles: [],  points: points, outline: outline)
}
