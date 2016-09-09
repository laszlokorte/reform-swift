//
//  ProjectNormalizer.swift
//  ReformSerializer
//
//  Created by Laszlo Korte on 31.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformExpression
import ReformCore

extension Project : Normalizable {

    public func normalize() throws -> NormalizedValue {
        return .dictionary([
            "pictures" : .array(try self.pictures.map { picture in
                return try picture.normalize()
            })
        ])
    }

    public convenience init(normalizedValue: NormalizedValue) throws {
        guard case .array(let pics) = normalizedValue else {
            throw InitialisationError.unknown
        }

        self.init(pictures: try pics.map(Picture.init))
    }
}

extension FormIdentifier : Normalizable {
    public func normalize() throws -> NormalizedValue {
        return .int(value)
    }

    public init(normalizedValue: NormalizedValue) throws {
        guard case .int(let value) = normalizedValue else {
            throw InitialisationError.unknown
        }

        self.init(value)
    }
}

extension ExposedPointIdentifier : Normalizable {
    public func normalize() throws -> NormalizedValue {
        return .int(value)
    }

    public init(normalizedValue: NormalizedValue) throws {
        guard case .int(let value) = normalizedValue else {
            throw InitialisationError.unknown
        }

        self.init(value)
    }
}

extension AnchorIdentifier : Normalizable {
    public func normalize() -> NormalizedValue {
        return .int(value)
    }


    public init(normalizedValue: NormalizedValue) throws {
        guard case .int(let value) = normalizedValue else {
            throw InitialisationError.unknown
        }

        self.init(value)
    }
}

extension ReferenceId : Normalizable {
    public func normalize() -> NormalizedValue {
        return .int(value)
    }

    public init(normalizedValue: NormalizedValue) throws {
        guard case .int(let value) = normalizedValue else {
            throw InitialisationError.unknown
        }

        self.init(value)
    }
}

extension PictureIdentifier : Normalizable {
    public func normalize() -> NormalizedValue {
        return .int(value)
    }

    public init(normalizedValue: NormalizedValue) throws {
        guard case .int(let value) = normalizedValue else {
            throw InitialisationError.unknown
        }

        self.init(value)
    }
}

extension ReformCore.Picture : Normalizable {
    private enum Keys : String {
        case Id
        case Name
        case Size
        case Width
        case Height
        case Procedure
        case Data
    }

    public func normalize() throws -> NormalizedValue {
        guard let normalizableData = data as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: data))
        }

        return .dictionary([
            Keys.Id.rawValue : identifier.normalize(),
            Keys.Name.rawValue : .string(name),
            Keys.Size.rawValue : NormalizedValue.dictionary([
                Keys.Width.rawValue: NormalizedValue.double(size.0),
                Keys.Height.rawValue: NormalizedValue.double(size.1)
            ]),
            Keys.Procedure.rawValue : try procedure.normalize(),
            Keys.Data.rawValue : try normalizableData.normalize()
        ])
    }

    public convenience init(normalizedValue: NormalizedValue) throws {
        guard case .dictionary(let dict) = normalizedValue,
            let
            id = dict[Keys.Id.rawValue],
            case .string(let name)? = dict[Keys.Name.rawValue],
            case .dictionary(let size)? = dict[Keys.Size.rawValue],
            case .double(let width)? = size[Keys.Width.rawValue],
            case .double(let height)? = size[Keys.Height.rawValue],
            let proc = dict[Keys.Procedure.rawValue],
            let data = dict[Keys.Data.rawValue]
            else {
            throw InitialisationError.unknown
        }

        self.init(identifier : try PictureIdentifier(normalizedValue: id),
            name: name,
            size: (width, height),
            data: try BaseSheet(normalizedValue: data),
            procedure : try Procedure(normalizedValue: proc))
    }
}

extension BaseSheet : Normalizable {
    public func normalize() throws -> NormalizedValue {
        return .dictionary([
            "Definitions" : .array([])
        ])
    }

    public convenience init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension Procedure : Normalizable {

    public func normalize() throws -> NormalizedValue {
        guard case .group(_, let children) = root.content else {
            throw NormalizationError.notNormalizable(type(of: root.content))
        }

        return .array(try children.filter({!($0.isEmpty)}).map{try $0.normalize()})
    }

    public convenience init(normalizedValue: NormalizedValue) throws {
        guard case .array(let root) = normalizedValue else {
            throw InitialisationError.unknown
        }

        self.init(children: try root.map(InstructionNode.init))
    }
}

extension InstructionNode : Normalizable {
    private enum Keys : String {
        case Single
        case InstructionType
        case Group
        case Children
    }

    public func normalize() throws -> NormalizedValue {
        switch self.content {
        case .null:
            return .dictionary([
                Keys.InstructionType.rawValue : .string("Null"),
                ])
        case .single(let instruction):
            guard let normalizable = instruction as? Normalizable else {
                throw NormalizationError.notNormalizable(type(of: instruction))
            }
            return .dictionary([
                Keys.InstructionType.rawValue : .string(String(describing: type(of: normalizable))),
                Keys.Single.rawValue : try normalizable.normalize()
            ])
        case .group(let group, let children):
            guard let normalizable = group as? Normalizable else {
                throw NormalizationError.notNormalizable(type(of: group))
            }
            return .dictionary([
                Keys.InstructionType.rawValue : .string(String(describing: type(of: normalizable))),
                Keys.Group.rawValue : try normalizable.normalize(),
                Keys.Children.rawValue : .array(try children.filter({!($0.isEmpty)}).map { node in
                    return try node.normalize()
                })
            ])
        }
    }

    public convenience init(normalizedValue: NormalizedValue) throws {
        if case .null = normalizedValue {
            self.init()
        } else if case .dictionary(let dict) = normalizedValue {
            if let single = dict[Keys.Single.rawValue],
                let type = dict[Keys.InstructionType.rawValue] {
                self.init(instruction: try instructionType(type).init(normalizedValue: single))
            } else if
                let group = dict[Keys.Group.rawValue],
                let type = dict[Keys.InstructionType.rawValue],
                case .array(let children)? = dict[Keys.Children.rawValue] {
                    self.init(group: try instructionType(type).init(normalizedValue: group), children: try children.map(InstructionNode.init))

            } else {
                throw InitialisationError.unknown
            }
        } else {
            throw InitialisationError.unknown
        }
    }
}

func instructionType(_ normalizedValue: NormalizedValue) throws -> protocol<Instruction, Normalizable>.Type {
    guard case .string(let type) = normalizedValue else {
        throw InitialisationError.unknown

    }

    switch type {
    case String(describing: CreateFormInstruction.self):
        return CreateFormInstruction.self
    case String(describing: MorphInstruction.self):
        return MorphInstruction.self
    case String(describing: TranslateInstruction.self):
        return TranslateInstruction.self
    case String(describing: ScaleInstruction.self):
        return ScaleInstruction.self
    case String(describing: RotateInstruction.self):
        return RotateInstruction.self

    default:
        throw InitialisationError.unknown

    }
}

func instructionType(_ normalizedValue: NormalizedValue) throws -> protocol<GroupInstruction, Normalizable>.Type {
    guard case .string(let type) = normalizedValue else {
        throw InitialisationError.unknown

    }

    switch type {
    case String(describing: ForLoopInstruction.self):
        return ForLoopInstruction.self
    case String(describing: IfConditionInstruction.self):
        return IfConditionInstruction.self

    default:
        throw InitialisationError.unknown
        
    }
}

extension CreateFormInstruction : Normalizable {

    public func normalize() throws -> NormalizedValue {
        guard let normalizableForm = form as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: form))
        }
        guard let normalizableDestination = destination as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: destination))
        }
        return .dictionary([
            "formType" : .string(String(describing: type(of: form))),
            "form" : try normalizableForm.normalize(),
            "destinationType" : .string(String(describing: type(of: destination))),
            "destination" : try normalizableDestination.normalize()
        ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        guard case .dictionary(let dict) = normalizedValue,
            let ftype = dict["formType"],
            let dtype = dict["destinationType"],
            let form = dict["form"], let destination = dict["destination"] else {
                throw InitialisationError.unknown
        }

        self.init(form: try formType(ftype).init(normalizedValue: form), destination: try destinationType(dtype).init(normalizedValue: destination))
    }
}

func formType(_ normalizedValue: NormalizedValue) throws -> protocol<ReformCore.Form, Normalizable, Creatable>.Type {
    guard case .string(let type) = normalizedValue else {
        throw InitialisationError.unknown

    }

    switch type {
    case String(describing: LineForm.self):
        return LineForm.self
    case String(describing: RectangleForm.self):
        return RectangleForm.self
    case String(describing: CircleForm.self):
        return CircleForm.self
    case String(describing: PieForm.self):
        return PieForm.self
    case String(describing: ArcForm.self):
        return ArcForm.self
    case String(describing: TextForm.self):
        return TextForm.self
    case String(describing: PictureForm.self):
        return PictureForm.self

    default:
        throw InitialisationError.unknown
        
    }
}


func destinationType(_ normalizedValue: NormalizedValue) throws -> protocol<RuntimeInitialDestination, Normalizable, Labeled>.Type {
    throw InitialisationError.unknown

}



extension MorphInstruction : Normalizable {

    public func normalize() throws -> NormalizedValue {
        guard let normalizableDistance = distance as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: distance))
        }
        return .dictionary([
            "formId" : try formId.normalize(),
            "anchorId" : anchorId.normalize(),
            "distance" : try normalizableDistance.normalize()
        ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}


extension TranslateInstruction : Normalizable {

    public func normalize() throws -> NormalizedValue {
        guard let normalizableDistance = distance as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: distance))
        }
        return .dictionary([
            "formId" : try formId.normalize(),
            "distance" : try normalizableDistance.normalize()
        ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}


extension RotateInstruction : Normalizable {

    public func normalize() throws -> NormalizedValue {
        guard let normalizableAngle = angle as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: angle))
        }
        guard let normalizablePoint = fixPoint as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: fixPoint))
        }
        return .dictionary([
            "formId" : try formId.normalize(),
            "angle" : try normalizableAngle.normalize(),
            "fixPoint" : try normalizablePoint.normalize(),
            ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}



extension ScaleInstruction : Normalizable {

    public func normalize() throws -> NormalizedValue {
        guard let normalizableFactor = factor as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: factor))
        }
        guard let normalizableAxis = axis as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: axis))
        }
        guard let normalizablePoint = fixPoint as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: fixPoint))
        }
        return .dictionary([
            "formId" : try formId.normalize(),
            "factor" : try normalizableFactor.normalize(),
            "axis" : try normalizableAxis.normalize(),
            "fixPoint" : try normalizablePoint.normalize(),
            ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}



extension IfConditionInstruction : Normalizable {

    public func normalize() throws -> NormalizedValue {
        return .dictionary([
            "expression" : try expression.normalize()
        ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}



extension ForLoopInstruction : Normalizable {

    public func normalize() throws -> NormalizedValue {
        return .dictionary([
            "expression" : try expression.normalize()
            ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension FormIteratorInstruction : Normalizable {

    public func normalize() throws -> NormalizedValue {
        return .dictionary([
            "proxyForm" : try proxyForm.normalize(),
            "formIds" : .array(try formIds.map({try $0.normalize()}))
            ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}



extension DrawingMode : Normalizable {
    public func normalize() -> NormalizedValue {
        switch self {
        case .draw:
            return .string("Draw")
        case .guide:
            return .string("Guide")
        case .mask:
            return .string("Mask")
        }
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension ReformCore.Form where Self: Drawable, Self:Creatable {

    public func normalize() throws -> NormalizedValue {
        return .dictionary([
            "type" : .string(String(describing: Self.self)),
            "name" : .string(name),
            "identifier" : try identifier.normalize(),
            "drawingMode" : drawingMode.normalize()
            ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension ProxyForm : Normalizable {

    public func normalize() throws -> NormalizedValue {
        return .dictionary([
            "name" : .string(name),
            "identifier" : try identifier.normalize(),
        ])
    }

    public convenience init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension ReformExpression.Expression : Normalizable {

    public func normalize() throws -> NormalizedValue {
        switch self {
        case .constant(let value):
            return .dictionary(["constant": try value.normalize()])
        case .namedConstant(let name, let value):
            return .dictionary(["namedConstant": try value.normalize(), "name" : .string(name)])
        case .reference(let refid):
            return .dictionary(["reference": refid.normalize()])
        case .unary(let op, let sub):
            return .dictionary(["unary": .string(String(describing: type(of: op))), "sub": try sub.normalize()])
        case .binary(let op, let lhs, let rhs):
            return .dictionary(["binary": NormalizedValue.string(String(describing: type(of: op))), "lhs": try lhs.normalize(), "rhs": try rhs.normalize()])
        case .call(let function, let params):
            return .dictionary([
                "function": .string(String(describing: type(of: function))),
                "params": .array(try params.map({try $0.normalize()}))
            ])
        }
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}


extension ReformExpression.Value : Normalizable {

    public func normalize() throws -> NormalizedValue {
        switch self {
        case .stringValue(let value):
            return .string(value)
        case .intValue(let value):
            return .int(value)
        case .doubleValue(let value):
            return .double(value)
        case .colorValue(let r, let g, let b, let a):
            return .dictionary([
                "color": .int(Int(r)<<24 | Int(g) << 16 | Int(b) << 8 | Int(a))
            ])
        case .boolValue(let value):
            return .bool(value)
        }
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension RelativeDestination : Normalizable {
    public func normalize() throws -> NormalizedValue {
        guard let from = self.from as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: self.from))
        }

        guard let to = self.to as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: self.to))
        }

        guard let direction = self.direction as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: self.direction))
        }


        return .dictionary([
            "fromType" :
                .string(String(describing: type(of: from))),
            "from" : try from.normalize(),
            "toType" : .string(String(describing: type(of: to))),
            "to" : try to.normalize(),
            "directionType" : .string(String(describing: type(of: direction))),
            "direction" : try direction.normalize(),
            "alignment" : try alignment.normalize()
            ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension FixSizeDestination : Normalizable {
    public func normalize() throws -> NormalizedValue {
        guard let from = self.from as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: self.from))
        }

        return .dictionary([
            "fromType" :
                .string(String(describing: type(of: from))),
            "from" : try from.normalize(),
            "delta" : delta.normalize(),
            "alignment" : try alignment.normalize()
            ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension RelativeDistance : Normalizable {
    public func normalize() throws -> NormalizedValue {
        guard let from = self.from as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: self.from))
        }

        guard let to = self.to as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: self.to))
        }

        guard let direction = self.direction as? Normalizable else {
            throw NormalizationError.notNormalizable(type(of: self.direction))
        }

        return .dictionary([
            "from" : try from.normalize(),
            "to" : try to.normalize(),
            "direction" : try direction.normalize()
        ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension ForeignFormPoint : Normalizable {
    public func normalize() throws -> NormalizedValue {
        return .dictionary([
            "formId" : try formId.normalize(),
            "pointId" : try pointId.normalize()
        ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension GlompPoint : Normalizable {
    public func normalize() throws -> NormalizedValue {
        return .dictionary([
            "formId" : try formId.normalize(),
            "lerp" : try lerp.normalize()
            ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension GridPoint : Normalizable {
    public func normalize() throws -> NormalizedValue {
        return .dictionary([
            "percent" : percent.normalize()
        ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension RuntimeAlignment : Normalizable {
    public func normalize() throws -> NormalizedValue {
        return .string(String(describing: self))
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension Cartesian : Normalizable {
    public func normalize() throws -> NormalizedValue {
        return .string(String(describing: self))
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension FreeDirection : Normalizable {
    public func normalize() throws -> NormalizedValue {
        return .string("Free")
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension ProportionalDirection : Normalizable {
    public func normalize() throws -> NormalizedValue {
        return .dictionary([
            "numerator": .int(self.proportion.0),
            "denominator": .int(self.proportion.1),
            "large": .bool(self.large)
        ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension ConstantAngle : Normalizable {
    public func normalize() throws -> NormalizedValue {
        return .dictionary(["angle": self.angle.normalize()])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension Angle : Normalizable {
    public func normalize() -> NormalizedValue {
        return .double(self.radians)
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}



extension Vec2d : Normalizable {
    public func normalize() -> NormalizedValue {
        return .dictionary([
            "x" : .double(self.x),
            "y" : .double(self.y)
        ])
    }

    public init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.unknown
    }
}

extension RectangleForm : Normalizable {
}
extension LineForm : Normalizable {
}
extension CircleForm : Normalizable {
}
extension TextForm : Normalizable {
}
extension ArcForm : Normalizable {
}
extension PieForm : Normalizable {
}
extension PictureForm : Normalizable {
}
