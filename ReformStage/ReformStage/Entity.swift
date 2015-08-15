//
//  Entity.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformMath

struct Entity {
    let id : FormIdentifier
    let label : String
    let type : EntityType
    
    let handles : [Handle]
    let points : [EntityPoint]
    let outline: SegmentPath
}

extension Entity : Hashable {
    var hashValue : Int { return id.hashValue }
}

func ==(lhs: Entity, rhs: Entity) -> Bool {
    return lhs.id == rhs.id
}

enum EntityType {
    case Draw
    case Mask
    case Guide
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

struct EntityPoint : SnapPoint {
    let position : Vec2d
    let label : String
    let formId : FormIdentifier
    let pointId : ExposedPointIdentifier
    
    var runtimePoint : LabeledPoint {
        return ForeignFormPoint(formId: formId, pointId: pointId)
    }
}


func entityForRuntimeForm(runtime: Runtime, formId: FormIdentifier) -> Entity? {

    guard let form = runtime.get(formId) else {
        return nil
    }
    
    switch form {
    case let form as LineForm:
        return entityForRuntimeForm(runtime, line: form)
    case let form as RectangleForm:
        return entityForRuntimeForm(runtime, rectangle: form)
    case let form as CircleForm:
        return entityForRuntimeForm(runtime, circle: form)
    case let form as PieForm:
        return entityForRuntimeForm(runtime, pie: form)
    case let form as ArcForm:
        return entityForRuntimeForm(runtime, arc: form)
    case let form as TextForm:
        return entityForRuntimeForm(runtime, text: form)
    case let form as PictureForm:
        return entityForRuntimeForm(runtime, picture: form)
    default:
        return nil
    }
}


func entityForRuntimeForm(runtime: Runtime, line form: LineForm) -> Entity {
    let type = EntityType(drawingMode: form.drawingMode)
    let handles = [Handle]()
    let points = [EntityPoint]()
    let outline = form.outline.getSegmentsFor(runtime)
    
    return Entity(id: form.identifier, label: form.name, type: type, handles: handles, points: points, outline: outline)
}

func entityForRuntimeForm(runtime: Runtime, rectangle form: RectangleForm) -> Entity {
    let type = EntityType(drawingMode: form.drawingMode)
    let handles = [Handle]()
    let points = [EntityPoint]()
    let outline = form.outline.getSegmentsFor(runtime)
    
    return Entity(id: form.identifier, label: form.name, type: type, handles: handles, points: points, outline: outline)
}

func entityForRuntimeForm(runtime: Runtime, circle form: CircleForm) -> Entity {
    let type = EntityType(drawingMode: form.drawingMode)
    let handles = [Handle]()
    let points = [EntityPoint]()
    let outline = form.outline.getSegmentsFor(runtime)
    
    return Entity(id: form.identifier, label: form.name, type: type, handles: handles, points: points, outline: outline)
}

func entityForRuntimeForm(runtime: Runtime, pie form: PieForm) -> Entity {
    let type = EntityType(drawingMode: form.drawingMode)
    let handles = [Handle]()
    let points = [EntityPoint]()
    let outline = form.outline.getSegmentsFor(runtime)
    
    return Entity(id: form.identifier, label: form.name, type: type, handles: handles, points: points, outline: outline)
}


func entityForRuntimeForm(runtime: Runtime, arc form: ArcForm) -> Entity {
    let type = EntityType(drawingMode: form.drawingMode)
    let handles = [Handle]()
    let points = [EntityPoint]()
    let outline = form.outline.getSegmentsFor(runtime)
    
    return Entity(id: form.identifier, label: form.name, type: type, handles: handles, points: points, outline: outline)
}



func entityForRuntimeForm(runtime: Runtime, text form: TextForm) -> Entity {
    let type = EntityType(drawingMode: form.drawingMode)
    let handles = [Handle]()
    let points = [EntityPoint]()
    let outline = form.outline.getSegmentsFor(runtime)
    
    return Entity(id: form.identifier, label: form.name, type: type, handles: handles, points: points, outline: outline)
}


func entityForRuntimeForm(runtime: Runtime, picture form: PictureForm) -> Entity {
    let type = EntityType(drawingMode: form.drawingMode)
    let handles = [Handle]()
    let points = [EntityPoint]()
    let outline = form.outline.getSegmentsFor(runtime)
    
    return Entity(id: form.identifier, label: form.name, type: type, handles: handles, points: points, outline: outline)
}