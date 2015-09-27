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
    case Form(FormIdentifier)
    case Proxy(proxy: FormIdentifier, instance: FormIdentifier)

    public init(form id: FormIdentifier) {
        self = Form(id)
    }

    public init(proxy: FormIdentifier, id: FormIdentifier) {
        self = Proxy(proxy: proxy, instance: id)
    }

    public var runtimeId : FormIdentifier {
        switch self {
        case Form(let id):
            return id
        case .Proxy(let id, _):
            return id
        }
    }
}

extension SourceIdentifier : Hashable {
    public var hashValue : Int {
        switch self {
        case Form(let id):
            return id.hashValue
        case .Proxy(let p, let i):
            return p.hashValue + 13 * i.hashValue
        }
    }
}

public func matches(lhs: SourceIdentifier, id rhs: FormIdentifier) -> Bool {
    switch lhs {
    case .Form(let id):
        return id == rhs
    case .Proxy(let proxyId, let id):
        return proxyId == rhs
            || id == rhs
    }
}

public func intersects(lhs: SourceIdentifier, id rhs: SourceIdentifier) -> Bool {
    switch lhs {
    case .Form(let id):
        switch rhs {
        case .Form(let a):
            return id == a
        case .Proxy(let a, let b):
            return id == a || id == b
        }
    case .Proxy(let proxyId, let id):
        switch rhs {
        case .Form(let a):
            return id == a || proxyId == a
        case .Proxy(let a, let b):
            return id == a
                || id == b
                || proxyId == a
                || proxyId == b
        }
    }
}

public func ==(lhs: SourceIdentifier, rhs: SourceIdentifier) -> Bool {
    switch (lhs, rhs) {
    case (.Form(let l), .Form(let r)):
        return l == r
    case (.Proxy(let p1, let i1), .Proxy(let p2, let i2)):
        return p1 == p2 && i1 == i2
    default:
        return false
    }
}

public struct Entity {
    public let formType : Form.Type
    public let id : SourceIdentifier
    public let label : String
    public let type : EntityType
    public let hitArea : HitArea
    
    public let handles : [Handle]
    public let affineHandles : [AffineHandle]
    public let points : [EntityPoint]
    public let outline: SegmentPath

    init(formType: Form.Type, id: SourceIdentifier, label: String, type: EntityType, hitArea: HitArea, handles: [Handle], affineHandles: [AffineHandle], points: [EntityPoint], outline: SegmentPath) {
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
    case Draw
    case Mask
    case Guide
    case Canvas
    case Proxy
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
    public let formId : SourceIdentifier
    public let pointId : ExposedPointIdentifier
    
    public var runtimePoint : LabeledPoint {
        return ForeignFormPoint(formId: formId.runtimeId, pointId: pointId)
    }
    
    public func belongsTo(formId: FormIdentifier) -> Bool {
        return self.formId.runtimeId == formId
    }
}


public func ==(lhs: EntityPoint, rhs: EntityPoint) -> Bool {
    return lhs.position == rhs.position && lhs.label == rhs.label && lhs.formId == rhs.formId && lhs.pointId == rhs.pointId
}

func createEntityPoint<R:Runtime, A:Analyzer>(analyzer: A, runtime: R, formId: FormIdentifier, pointId: ExposedPointIdentifier, sourceId: SourceIdentifier? = nil) -> EntityPoint? {
    guard let
        point = runtime.get(formId)?.getPoints()[pointId],
        position = point.getPositionFor(runtime) else {
        return nil
    }
    
    return EntityPoint(position: position, label: point.getDescription(analyzer.stringifier), formId: sourceId ?? .Form(formId), pointId: pointId)
}


func entityForRuntimeForm<R:Runtime, A:Analyzer>(analyzer: A, runtime: R, formId: FormIdentifier) -> Entity? {

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

func collectAffineHandles<F:Form,  R:Runtime, A:Analyzer>(analyzer: A, runtime: R, form: F, pivots: [ExposedPointIdentifier:(ExposedPointIdentifier,ExposedPointIdentifier, axisName: String?)], sourceId: SourceIdentifier? = nil) -> [AffineHandle] {
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
            axis = .Named(axisname, formId: form.identifier, pivot.0, pivot.1)
        } else {
            axis = .None
        }

        return AffineHandle(formId: .Form(form.identifier), pointId: pointId, label: point.getDescription(analyzer.stringifier), position: position, defaultPivot: (primary, secondary), scaleAxis: axis
        )
    }
}

func collectHandles<F:Form,  R:Runtime, A:Analyzer where F:Morphable>(analyzer: A, runtime: R, form: F, points: [AnchorIdentifier: ExposedPointIdentifier]) -> [Handle] {
    return form.getAnchors().flatMap() { (anchorId, anchor) -> Handle? in
        guard let
            position = anchor.getPositionFor(runtime),
            pointId = points[anchorId] else {
                return nil
        }

        return Handle(formId: .Form(form.identifier), anchorId: anchorId, pointId: pointId, label: anchor.name, position: position)
    }
}

func collectPoints<R:Runtime, A:Analyzer>(analyzer: A, runtime: R, form: Form, sourceId: SourceIdentifier? = nil) -> [EntityPoint] {
        return form.getPoints().flatMap { (pointId, point) -> EntityPoint? in
            guard let position = point.getPositionFor(runtime) else {
                return nil
            }
            
            return EntityPoint(position: position, label: point.getDescription(analyzer.stringifier), formId: sourceId ?? .Form(form.identifier), pointId: pointId)
        }
}


func entityForRuntimeForm<R:Runtime, A:Analyzer>(analyzer: A, runtime: R, line form: LineForm) -> Entity? {
    guard let
        start = form.startAnchor.getPositionFor(runtime),
        end = form.endAnchor.getPositionFor(runtime) else {
        return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        LineForm.PointId.Start.rawValue : (LineForm.PointId.End.rawValue, LineForm.PointId.Center.rawValue, nil),
        LineForm.PointId.End.rawValue : (LineForm.PointId.Start.rawValue, LineForm.PointId.Center.rawValue, nil),
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
        LineForm.AnchorId.Start.rawValue : LineForm.PointId.Start.rawValue,
        LineForm.AnchorId.End.rawValue : LineForm.PointId.End.rawValue,
    ])
    
    let points = collectPoints(analyzer, runtime: runtime, form: form)
        
    let outline = form.outline.getSegmentsFor(runtime)
        
    let hit = HitArea.Line(LineSegment2d(from: start, to: end))
    
    return Entity(formType: form.dynamicType, id: .Form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles, points: points, outline: outline)
}

func entityForRuntimeForm<R:Runtime, A:Analyzer>(analyzer: A, runtime: R, rectangle form: RectangleForm) -> Entity? {
    guard let
        topLeft = form.topLeftAnchor.getPositionFor(runtime),
        topRight = form.topRightAnchor.getPositionFor(runtime),
        bottomLeft = form.bottomLeftAnchor.getPositionFor(runtime),
        bottomRight = form.bottomRightAnchor.getPositionFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        RectangleForm.PointId.TopLeft.rawValue :
            (RectangleForm.PointId.BottomRight.rawValue, RectangleForm.PointId.Center.rawValue, nil),
        
        RectangleForm.PointId.TopRight.rawValue :
            (RectangleForm.PointId.BottomLeft.rawValue, RectangleForm.PointId.Center.rawValue, nil),
        
        RectangleForm.PointId.BottomLeft.rawValue :
            (RectangleForm.PointId.TopRight.rawValue, RectangleForm.PointId.Center.rawValue, nil),
        
        RectangleForm.PointId.BottomRight.rawValue :
            (RectangleForm.PointId.TopLeft.rawValue, RectangleForm.PointId.Center.rawValue, nil),
        
        RectangleForm.PointId.Top.rawValue :
            (RectangleForm.PointId.Bottom.rawValue, RectangleForm.PointId.Center.rawValue, "Height"),
        
        RectangleForm.PointId.Bottom.rawValue :
            (RectangleForm.PointId.Top.rawValue,
                RectangleForm.PointId.Center.rawValue, "Height"),
        
        RectangleForm.PointId.Left.rawValue :
            (RectangleForm.PointId.Right.rawValue, RectangleForm.PointId.Center.rawValue, "Width"),
        
        RectangleForm.PointId.Right.rawValue :
            (RectangleForm.PointId.Left.rawValue,
                RectangleForm.PointId.Center.rawValue, "Width"),
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
        RectangleForm.AnchorId.TopLeft.rawValue :
            RectangleForm.PointId.TopLeft.rawValue,

        RectangleForm.AnchorId.TopRight.rawValue :
            RectangleForm.PointId.TopRight.rawValue,

        RectangleForm.AnchorId.BottomLeft.rawValue :
            RectangleForm.PointId.BottomLeft.rawValue,

        RectangleForm.AnchorId.BottomRight.rawValue :
            RectangleForm.PointId.BottomRight.rawValue,

        RectangleForm.AnchorId.Top.rawValue :
            RectangleForm.PointId.Top.rawValue,

        RectangleForm.AnchorId.Bottom.rawValue :
            RectangleForm.PointId.Bottom.rawValue,

        RectangleForm.AnchorId.Left.rawValue :
            RectangleForm.PointId.Left.rawValue,

        RectangleForm.AnchorId.Right.rawValue :
            RectangleForm.PointId.Right.rawValue,
        ])

    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let hit = HitArea.Union(
        HitArea.Triangle(Triangle2d(a: topLeft, b: topRight, c: bottomRight)),
        HitArea.Triangle(Triangle2d(a: topLeft, b: bottomRight, c: bottomLeft))
    )
    
    return Entity(formType: form.dynamicType, id: .Form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles, points: points, outline: outline)
}

func entityForRuntimeForm<R:Runtime, A:Analyzer>(analyzer: A, runtime: R, circle form: CircleForm) -> Entity? {
    guard let
        center = form.centerPoint.getPositionFor(runtime),
        radius = form.radius.getLengthFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        CircleForm.PointId.Top.rawValue : (
            CircleForm.PointId.Center.rawValue,
            CircleForm.PointId.Bottom.rawValue, nil),
        
        CircleForm.PointId.Bottom.rawValue : (
            CircleForm.PointId.Center.rawValue,
            CircleForm.PointId.Top.rawValue, nil),
        
        CircleForm.PointId.Left.rawValue : (
            CircleForm.PointId.Center.rawValue,
            CircleForm.PointId.Right.rawValue, nil),
        
        CircleForm.PointId.Right.rawValue : (
            CircleForm.PointId.Center.rawValue,
            CircleForm.PointId.Left.rawValue, nil),
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
        CircleForm.AnchorId.Top.rawValue :
            CircleForm.PointId.Top.rawValue,

        CircleForm.AnchorId.Bottom.rawValue :
            CircleForm.PointId.Bottom.rawValue,

        CircleForm.AnchorId.Left.rawValue :
            CircleForm.PointId.Left.rawValue,

        CircleForm.AnchorId.Right.rawValue :
            CircleForm.PointId.Right.rawValue,
        ])
    
    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let hit = HitArea.Circle(Circle2d(center: center, radius: radius))
    
    return Entity(formType: form.dynamicType, id: .Form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles,  points: points, outline: outline)
}

func entityForRuntimeForm<R:Runtime, A:Analyzer>(analyzer: A, runtime: R, pie form: PieForm) -> Entity? {
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
        PieForm.PointId.Start.rawValue : (
            PieForm.PointId.Center.rawValue,
            PieForm.PointId.End.rawValue, nil),
        
        PieForm.PointId.End.rawValue : (
            PieForm.PointId.Center.rawValue,
            PieForm.PointId.Start.rawValue, nil),
        
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
        PieForm.AnchorId.Start.rawValue :
            PieForm.PointId.Start.rawValue,

        PieForm.AnchorId.End.rawValue :
            PieForm.PointId.End.rawValue,

        ])

    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let hit = HitArea.Intersection(
        HitArea.Arc(Arc2d(center: center, radius: radius, range: AngleRange(start: lowerAngle, end: upperAngle))),
        HitArea.Sector(center: center, range: AngleRange(start: lowerAngle, end: upperAngle))
    )
    
    return Entity(formType: form.dynamicType, id: .Form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles,  points: points, outline: outline)
}


func entityForRuntimeForm<R:Runtime, A:Analyzer>(analyzer: A, runtime: R, arc form: ArcForm) -> Entity? {
    guard let
        start = form.startPoint.getPositionFor(runtime),
        end = form.endPoint.getPositionFor(runtime),
        center = form.centerPoint.getPositionFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        ArcForm.PointId.Start.rawValue : (
            ArcForm.PointId.End.rawValue,
            ArcForm.PointId.Center.rawValue, nil),
        
        ArcForm.PointId.End.rawValue : (
            ArcForm.PointId.Start.rawValue,
            ArcForm.PointId.Center.rawValue, nil),
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
        ArcForm.AnchorId.Start.rawValue : ArcForm.PointId.Start.rawValue,

        ArcForm.AnchorId.End.rawValue : ArcForm.PointId.End.rawValue,

        ArcForm.AnchorId.Center.rawValue : ArcForm.PointId.Center.rawValue,
    ])

    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let radius = (start - center).length

    let hit : HitArea

    if let line = Line2d(from: end, direction: end-start) {
        hit = HitArea.Intersection(
            HitArea.Circle(Circle2d(center: center, radius: radius)),
            HitArea.LeftOf(line)
        )
    } else {
        hit = HitArea.Circle(Circle2d(center: center, radius: radius))
    }

    
    return Entity(formType: form.dynamicType, id: .Form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles,  points: points, outline: outline)
}



func entityForRuntimeForm<R:Runtime, A:Analyzer>(analyzer: A, runtime: R, text form: TextForm) -> Entity? {
    guard let
        start = form.startPoint.getPositionFor(runtime),
        end = form.endPoint.getPositionFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        TextForm.PointId.Start.rawValue : (
            TextForm.PointId.End.rawValue,
            TextForm.PointId.Bottom.rawValue, nil),
        
        TextForm.PointId.End.rawValue : (
            TextForm.PointId.Start.rawValue,
            TextForm.PointId.Bottom.rawValue, nil),
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
            TextForm.AnchorId.Start.rawValue :
            TextForm.PointId.Start.rawValue,

        TextForm.AnchorId.End.rawValue :
            TextForm.PointId.End.rawValue,

            TextForm.AnchorId.Top.rawValue :
            TextForm.PointId.Top.rawValue,
        ])

    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    let hit = HitArea.Line(LineSegment2d(from: start, to: end))
    
    return Entity(formType: form.dynamicType, id: .Form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles,  points: points, outline: outline)
}


func entityForRuntimeForm<R:Runtime, A:Analyzer>(analyzer: A, runtime: R, picture form: PictureForm) -> Entity? {
    
    guard let
        topLeft = form.topLeftAnchor.getPositionFor(runtime),
        topRight = form.topRightAnchor.getPositionFor(runtime),
        bottomLeft = form.bottomLeftAnchor.getPositionFor(runtime),
        bottomRight = form.bottomRightAnchor.getPositionFor(runtime) else {
            return nil
    }
    
    let type = EntityType(drawingMode: form.drawingMode)
    
    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [
        PictureForm.PointId.TopLeft.rawValue : (
            PictureForm.PointId.BottomRight.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.PointId.TopRight.rawValue : (
            PictureForm.PointId.BottomLeft.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.PointId.BottomLeft.rawValue : (
            PictureForm.PointId.TopRight.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.PointId.BottomRight.rawValue : (
            PictureForm.PointId.TopLeft.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.PointId.Top.rawValue : (
            PictureForm.PointId.Bottom.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.PointId.Bottom.rawValue : (
            PictureForm.PointId.Top.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.PointId.Left.rawValue : (
            PictureForm.PointId.Right.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        
        PictureForm.PointId.Right.rawValue : (
            PictureForm.PointId.Left.rawValue,
            PictureForm.PointId.Center.rawValue, nil),
        ])

    let handles = collectHandles(analyzer, runtime: runtime, form: form, points: [
        PictureForm.AnchorId.TopLeft.rawValue :
            PictureForm.PointId.TopLeft.rawValue,

        PictureForm.AnchorId.TopRight.rawValue :
            PictureForm.PointId.TopRight.rawValue,

        PictureForm.AnchorId.BottomLeft.rawValue :
            PictureForm.PointId.BottomLeft.rawValue,

        PictureForm.AnchorId.BottomRight.rawValue :
            PictureForm.PointId.BottomRight.rawValue,

        PictureForm.AnchorId.Top.rawValue :
            PictureForm.PointId.Top.rawValue,

        PictureForm.AnchorId.Bottom.rawValue :
            PictureForm.PointId.Bottom.rawValue,

        PictureForm.AnchorId.Left.rawValue :
            PictureForm.PointId.Left.rawValue,

        PictureForm.AnchorId.Right.rawValue :
            PictureForm.PointId.Right.rawValue,
    ])

    

    let points = collectPoints(analyzer, runtime: runtime, form: form)
    
    let outline = form.outline.getSegmentsFor(runtime)
    
    
    let hit = HitArea.Union(
        HitArea.Triangle(Triangle2d(a: topLeft, b: topRight, c: bottomRight)),
        HitArea.Triangle(Triangle2d(a: topLeft, b: bottomRight, c: bottomLeft))
    )
    
    return Entity(formType: form.dynamicType, id: .Form(form.identifier), label: form.name, type: type, hitArea: hit, handles: handles,affineHandles: affineHandles, points: points, outline: outline)
}


func entityForRuntimeForm<R:Runtime, A:Analyzer>(analyzer: A, runtime: R, paper form: ProxyForm) -> Entity? {
    let type = EntityType.Proxy

    guard let instanceId = form.getFormIdForRuntime(runtime) else {
        return nil
    }

    guard let aabb = form.outline.getAABBFor(runtime) else {
        return nil
    }


    let points = collectPoints(analyzer, runtime: runtime, form: form, sourceId: .Proxy(proxy: form.identifier, instance: instanceId))

    let affineHandles = collectAffineHandles(analyzer, runtime: runtime, form: form, pivots: [

        ProxyForm.PointId.TopLeft.rawValue : (
            ProxyForm.PointId.BottomRight.rawValue,
            ProxyForm.PointId.Center.rawValue, nil),

        ProxyForm.PointId.TopRight.rawValue : (
            ProxyForm.PointId.BottomLeft.rawValue,
            ProxyForm.PointId.Center.rawValue, nil),

        ProxyForm.PointId.BottomLeft.rawValue : (
            ProxyForm.PointId.TopRight.rawValue,
            ProxyForm.PointId.Center.rawValue, nil),

        ProxyForm.PointId.BottomRight.rawValue : (
            ProxyForm.PointId.TopLeft.rawValue,
            ProxyForm.PointId.Center.rawValue, nil),

        ProxyForm.PointId.Top.rawValue : (
            ProxyForm.PointId.Bottom.rawValue,
            ProxyForm.PointId.Center.rawValue, nil),

        ProxyForm.PointId.Bottom.rawValue : (
            ProxyForm.PointId.Top.rawValue,
            ProxyForm.PointId.Center.rawValue, nil),

        ProxyForm.PointId.Left.rawValue : (
            ProxyForm.PointId.Right.rawValue,
            ProxyForm.PointId.Center.rawValue, nil),

        ProxyForm.PointId.Right.rawValue : (
            ProxyForm.PointId.Left.rawValue,
            ProxyForm.PointId.Center.rawValue, nil),
        ], sourceId: .Proxy(proxy: form.identifier, instance: instanceId))

    let outline = form.outline.getSegmentsFor(runtime)

    let hit = HitArea.Union(
        HitArea.Triangle(Triangle2d(a: aabb.min, b: aabb.xMinYMax, c: aabb.max)),
        HitArea.Triangle(Triangle2d(a: aabb.max, b: aabb.xMaxYMin, c: aabb.min))
    )

    return Entity(formType: form.dynamicType, id: .Proxy(proxy: form.identifier, instance: instanceId), label: form.name, type: type, hitArea: hit, handles: [],affineHandles: affineHandles,  points: points, outline: outline)
}


func entityForRuntimeForm<R:Runtime, A:Analyzer>(analyzer: A, runtime: R, paper form: Paper) -> Entity? {

    let type = EntityType.Canvas

    let points = collectPoints(analyzer, runtime: runtime, form: form)

    let outline = form.outline.getSegmentsFor(runtime)

    let hit = HitArea.None
    return Entity(formType: form.dynamicType, id: .Form(form.identifier), label: form.name, type: type, hitArea: hit, handles: [],affineHandles: [],  points: points, outline: outline)
}