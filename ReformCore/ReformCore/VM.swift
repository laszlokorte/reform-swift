//
//  VM.swift
//  ReformCore
//
//  Created by Laszlo Korte on 09.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


typealias VMInstruction = Int
typealias VMProgramm = [VMInstruction]

enum VMError : ErrorType {
    case InvalidInstruction
}

class VM {
    private var stack = [Int]()
    private var programCounter: Int? = nil
    private var nextPC = Int?

    func run(program: VMProgramm) throws {
        while let pc = programCounter where pc < program.count {
            guard let instruction = VMOperatation(rawValue: program[pc]) else {
                throw VMError.InvalidInstruction
            }
            programCounter = instruction.executeOn(self, pc: pc)
        }
    }
}

enum VMOperatation : VMInstruction {
    case PushImmediate
    case Load
    case Store
    case Pop

    case MulInt
    case AddInt
    case SubInt
    case DivInt

    case MulFloat
    case AddFloat
    case SubFloat
    case DivFloat

    case Sin
    case Cos
    case Tan
    case ArcSin
    case ArcCos
    case ArcTan

    case Sqrt

    case LessThan
    case Equal

    case IntToFloat
    case FloatToInt

    case Halt

    private func executeOn(vm: VM, pc: Int) -> Int? {
        switch self {
        case PushImmediate:
            return pc + 1
        case Load:
            return pc + 1
        case Store:
            return pc + 1
        case Pop:
            return pc + 1

        case MulInt:
            return pc + 1
        case AddInt:
            return pc + 1
        case SubInt:
            return pc + 1
        case DivInt:
            return pc + 1

        case MulFloat:
            return pc + 1
        case AddFloat:
            return pc + 1
        case SubFloat:
            return pc + 1
        case DivFloat:
            return pc + 1

        case Sin:
            return pc + 1
        case Cos:
            return pc + 1
        case Tan:
            return pc + 1
        case ArcSin:
            return pc + 1
        case ArcCos:
            return pc + 1
        case ArcTan:
            return pc + 1

        case Sqrt:
            return pc + 1
            
        case LessThan:
            return pc + 1
        case Equal:
            return pc + 1
            
        case IntToFloat:
            return pc + 1
        case FloatToInt:
            return pc + 1
            
        case Halt:
            return nil
        }
    }
}