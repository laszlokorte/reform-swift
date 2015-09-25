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

    func normalize() throws -> NormalizedValue {
        return .Array(try self.pictures.map { picture in
            return try picture.normalize()
        })
    }

    convenience init(normalizedValue: NormalizedValue) throws {
        guard case .Array(let pics) = normalizedValue else {
            throw InitialisationError.Unknown
        }

        self.init(pictures: try pics.map(Picture.init))
    }
}

extension FormIdentifier : Normalizable {
    func normalize() -> NormalizedValue {
        return .Int(value)
    }

    init(normalizedValue: NormalizedValue) throws {
        guard case .Int(let value) = normalizedValue else {
            throw InitialisationError.Unknown
        }

        self.init(value)
    }
}

extension AnchorIdentifier : Normalizable {
    func normalize() -> NormalizedValue {
        return .Int(value)
    }


    init(normalizedValue: NormalizedValue) throws {
        guard case .Int(let value) = normalizedValue else {
            throw InitialisationError.Unknown
        }

        self.init(value)
    }
}

extension ReferenceId : Normalizable {
    func normalize() -> NormalizedValue {
        return .Int(value)
    }

    init(normalizedValue: NormalizedValue) throws {
        guard case .Int(let value) = normalizedValue else {
            throw InitialisationError.Unknown
        }

        self.init(value)
    }
}

extension PictureIdentifier : Normalizable {
    func normalize() -> NormalizedValue {
        return .Int(value)
    }

    init(normalizedValue: NormalizedValue) throws {
        guard case .Int(let value) = normalizedValue else {
            throw InitialisationError.Unknown
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

    func normalize() throws -> NormalizedValue {
        guard let normalizableData = data as? Normalizable else {
            throw NormalizationError.NotNormalizable(data.dynamicType)
        }

        return .Dictionary([
            Keys.Id.rawValue : identifier.normalize(),
            Keys.Name.rawValue : .String(name),
            Keys.Size.rawValue : NormalizedValue.Dictionary([
                Keys.Width.rawValue: NormalizedValue.Double(size.0),
                Keys.Height.rawValue: NormalizedValue.Double(size.1)
            ]),
            Keys.Procedure.rawValue : try procedure.normalize(),
            Keys.Data.rawValue : try normalizableData.normalize()
        ])
    }

    convenience init(normalizedValue: NormalizedValue) throws {
        guard case .Dictionary(let dict) = normalizedValue,
            let
            id = dict[Keys.Id.rawValue],
            case .String(let name)? = dict[Keys.Name.rawValue],
            case .Dictionary(let size)? = dict[Keys.Size.rawValue],
            case .Double(let width)? = size[Keys.Width.rawValue],
            case .Double(let height)? = size[Keys.Height.rawValue],
            let proc = dict[Keys.Procedure.rawValue],
            let data = dict[Keys.Data.rawValue]
            else {
            throw InitialisationError.Unknown
        }

        self.init(identifier : try PictureIdentifier(normalizedValue: id),
            name: name,
            size: (width, height),
            data: BaseSheet(),
            procedure : try Procedure(normalizedValue: proc))
    }
}

extension Procedure : Normalizable {
    private enum Keys : String {
        case Root
    }

    func normalize() throws -> NormalizedValue {
        guard case .Group(_, let children) = root.content else {
            throw NormalizationError.NotNormalizable(root.content.dynamicType)
        }

        return NormalizedValue.Dictionary([
            Keys.Root.rawValue : .Array(try children.map{try $0.normalize()})
        ])
    }

    convenience init(normalizedValue: NormalizedValue) throws {
        guard case .Dictionary(let dict) = normalizedValue,
            case .Array(let root)? = dict[Keys.Root.rawValue] else {
            throw InitialisationError.Unknown
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

    func normalize() throws -> NormalizedValue {
        switch self.content {
        case .Null:
            return .Null
        case .Single(let instruction):
            guard let normalizable = instruction as? Normalizable else {
                throw NormalizationError.NotNormalizable(instruction.dynamicType)
            }
            return .Dictionary([
                Keys.InstructionType.rawValue : .String(String(normalizable.dynamicType)),
                Keys.Single.rawValue : try normalizable.normalize()
            ])
        case .Group(let group, let children):
            guard let normalizable = group as? Normalizable else {
                throw NormalizationError.NotNormalizable(group.dynamicType)
            }
            return .Dictionary([
                Keys.InstructionType.rawValue : .String(String(normalizable.dynamicType)),
                Keys.Group.rawValue : try normalizable.normalize(),
                Keys.Children.rawValue : .Array(try children.map { node in
                    return try node.normalize()
                })
            ])
        }
    }

    convenience init(normalizedValue: NormalizedValue) throws {
        if case .Null = normalizedValue {
            self.init()
        } else if case .Dictionary(let dict) = normalizedValue {
            if let single = dict[Keys.Single.rawValue],
                type = dict[Keys.InstructionType.rawValue] {
                self.init(instruction: try instructionType(type).init(normalizedValue: single))
            } else if
                let group = dict[Keys.Group.rawValue],
                type = dict[Keys.InstructionType.rawValue],
                case .Array(let children)? = dict[Keys.Children.rawValue] {
                    self.init(group: try instructionType(type).init(normalizedValue: group), children: try children.map(InstructionNode.init))

            } else {
                throw InitialisationError.Unknown
            }
        } else {
            throw InitialisationError.Unknown
        }
    }
}

func instructionType(normalizedValue: NormalizedValue) throws -> protocol<Instruction, Normalizable>.Type {
    guard case .String(let type) = normalizedValue else {
        throw InitialisationError.Unknown

    }

    switch type {
    case String(CreateFormInstruction.self):
        return CreateFormInstruction.self
    case String(MorphInstruction.self):
        return MorphInstruction.self
    case String(TranslateInstruction.self):
        return TranslateInstruction.self
    case String(ScaleInstruction.self):
        return ScaleInstruction.self
    case String(RotateInstruction.self):
        return RotateInstruction.self

    default:
        throw InitialisationError.Unknown

    }
}

func instructionType(normalizedValue: NormalizedValue) throws -> protocol<GroupInstruction, Normalizable>.Type {
    guard case .String(let type) = normalizedValue else {
        throw InitialisationError.Unknown

    }

    switch type {
    case String(ForLoopInstruction.self):
        return ForLoopInstruction.self
    case String(IfConditionInstruction):
        return IfConditionInstruction.self

    default:
        throw InitialisationError.Unknown
        
    }
}

extension CreateFormInstruction : Normalizable {

    func normalize() throws -> NormalizedValue {
        guard let normalizableForm = form as? Normalizable else {
            throw NormalizationError.NotNormalizable(form.dynamicType)
        }
        guard let normalizableDestination = destination as? Normalizable else {
            throw NormalizationError.NotNormalizable(destination.dynamicType)
        }
        return .Dictionary([
            "formType" : .String(String(form.dynamicType)),
            "form" : try normalizableForm.normalize(),
            "destinationType" : .String(String(destination.dynamicType)),
            "destination" : try normalizableDestination.normalize()
        ])
    }

    init(normalizedValue: NormalizedValue) throws {
        guard case .Dictionary(let dict) = normalizedValue,
            let ftype = dict["formType"],
            dtype = dict["destinationType"],
            form = dict["form"], destination = dict["destination"] else {
                throw InitialisationError.Unknown
        }

        self.init(form: try formType(ftype).init(normalizedValue: form), destination: try destinationType(dtype).init(normalizedValue: destination))
    }
}

func formType(normalizedValue: NormalizedValue) throws -> protocol<Form, Normalizable, Creatable>.Type {
    guard case .String(let type) = normalizedValue else {
        throw InitialisationError.Unknown

    }

    switch type {
    case String(LineForm.self):
        return LineForm.self

    default:
        throw InitialisationError.Unknown
        
    }
}


func destinationType(normalizedValue: NormalizedValue) throws -> protocol<RuntimeInitialDestination, Normalizable, Labeled>.Type {
    throw InitialisationError.Unknown

}



extension MorphInstruction : Normalizable {

    func normalize() throws -> NormalizedValue {
        guard let normalizableDistance = distance as? Normalizable else {
            throw NormalizationError.NotNormalizable(distance.dynamicType)
        }
        return .Dictionary([
            "formId" : formId.normalize(),
            "anchorId" : anchorId.normalize(),
            "distance" : try normalizableDistance.normalize()
        ])
    }

    init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.Unknown
    }
}


extension TranslateInstruction : Normalizable {

    func normalize() throws -> NormalizedValue {
        guard let normalizableDistance = distance as? Normalizable else {
            throw NormalizationError.NotNormalizable(distance.dynamicType)
        }
        return .Dictionary([
            "formId" : formId.normalize(),
            "distance" : try normalizableDistance.normalize()
        ])
    }

    init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.Unknown
    }
}


extension RotateInstruction : Normalizable {

    func normalize() throws -> NormalizedValue {
        guard let normalizableAngle = angle as? Normalizable else {
            throw NormalizationError.NotNormalizable(angle.dynamicType)
        }
        guard let normalizablePoint = fixPoint as? Normalizable else {
            throw NormalizationError.NotNormalizable(fixPoint.dynamicType)
        }
        return .Dictionary([
            "formId" : formId.normalize(),
            "angle" : try normalizableAngle.normalize(),
            "fixPoint" : try normalizablePoint.normalize(),
            ])
    }

    init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.Unknown
    }
}



extension ScaleInstruction : Normalizable {

    func normalize() throws -> NormalizedValue {
        guard let normalizableFactor = factor as? Normalizable else {
            throw NormalizationError.NotNormalizable(factor.dynamicType)
        }
        guard let normalizableAxis = axis as? Normalizable else {
            throw NormalizationError.NotNormalizable(axis.dynamicType)
        }
        guard let normalizablePoint = fixPoint as? Normalizable else {
            throw NormalizationError.NotNormalizable(fixPoint.dynamicType)
        }
        return .Dictionary([
            "formId" : formId.normalize(),
            "factor" : try normalizableFactor.normalize(),
            "axis" : try normalizableAxis.normalize(),
            "fixPoint" : try normalizablePoint.normalize(),
            ])
    }

    init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.Unknown
    }
}



extension IfConditionInstruction : Normalizable {

    func normalize() throws -> NormalizedValue {
        return .Dictionary([
            "expression" : try expression.normalize()
        ])
    }

    init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.Unknown
    }
}



extension ForLoopInstruction : Normalizable {

    func normalize() throws -> NormalizedValue {
        return .Dictionary([
            "expression" : try expression.normalize()
        ])
    }

    init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.Unknown
    }
}

extension DrawingMode : Normalizable {
    func normalize() -> NormalizedValue {
        switch self {
        case .Draw:
            return .String("Draw")
        case .Guide:
            return .String("Guide")
        case .Mask:
            return .String("Mask")
        }
    }

    init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.Unknown
    }
}

extension Form where Self: Drawable {

    func normalize() throws -> NormalizedValue {
        return .Dictionary([
            "type" : .String(String(Self)),
            "name" : .String(name),
            "identifier" : identifier.normalize(),
            "drawingMode" : drawingMode.normalize()
            ])
    }
}

extension LineForm : Normalizable {
    convenience init(normalizedValue: NormalizedValue) throws {
        guard case .Dictionary(let dict) = normalizedValue,
            case .String(let name)? = dict["name"],
        let id = dict["identifier"] else {
            throw InitialisationError.Unknown
        }

        self.init(id: try FormIdentifier(normalizedValue: id), name: name)
    }

}

extension Expression : Normalizable {

    func normalize() throws -> NormalizedValue {
        switch self {
        case .Constant(let value):
            return .Dictionary(["constant": try value.normalize()])
        case .NamedConstant(let name, let value):
            return .Dictionary(["namedConstant": try value.normalize(), "name" : .String(name)])
        case .Reference(let refid):
            return .Dictionary(["reference": refid.normalize()])
        case .Unary(let op, let sub):
            return .Dictionary(["unary": .String(String(op.dynamicType)), "sub": try sub.normalize()])
        case .Binary(let op, let lhs, let rhs):
            return .Dictionary(["binary": NormalizedValue.String(String(op.dynamicType)), "lhs": try lhs.normalize(), "rhs": try rhs.normalize()])
        case .Call(let function, let params):
            return .Dictionary([
                "function": .String(String(function.dynamicType)),
                "params": .Array(try params.map({try $0.normalize()}))
            ])
        }
    }

    init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.Unknown
    }
}


extension Value : Normalizable {

    func normalize() throws -> NormalizedValue {
        switch self {
        case StringValue(let value):
            return .String(value)
        case IntValue(let value):
            return .Int(value)
        case DoubleValue(let value):
            return .Double(value)
        case ColorValue(let r, let g, let b, let a):
            return .Dictionary([
                "color": .Int(Int(r)<<24 | Int(g) << 16 | Int(b) << 8 | Int(a))
            ])
        case BoolValue(let value):
            return .Bool(value)
        }
    }

    init(normalizedValue: NormalizedValue) throws {
        throw InitialisationError.Unknown
    }
}

